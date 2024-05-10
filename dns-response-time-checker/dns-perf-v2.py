import socket
from dns import message, query
import json
import time
import statistics
import numpy as np
import pandas as pd

# If a resolver (such as a custom resolver on an app running locally) using dynamic ports
# this solution can be used (in original script Resolver() class will always assume port53 response)

NO_OF_SAMPLES = 3  # the number of times each site requested
OUTLIER_THRESHOLD = 100.0  # The response time that is considered an outlier


def main():
    # open the config file
    with open("conf.json", "r") as f:
        config = json.load(f)
        # nameservers from te json file
        nameservers = config["nameservers"]
        # domains list from the config file
        domains = config["domains"]
        # data dictionaries for the metrics to load into pandas
        data_avg = dict()
        data_med = dict()
        data_95th = dict()
        # list to keep track of outliers excluded from results
        outliers = list()
        # iterate through domains at the top level
        for domain in domains:
            # pull out the current gname and gtype from domain list element
            qname = domain.split(" ")[0]
            qtype = domain.split(" ")[1]
            # list to store the results by domain, so they can easily be passed to pandas
            domain_results_avg = list()
            domain_results_med = list()
            domain_results_95th = list()
            for ns in nameservers:
                # create a socket
                s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
                # set the target nameserver
                DNS_SERVER = ns["nameserver"]
                # request domain to warm up cache
                query = message.make_query(qname, qtype).to_wire()
                s.sendto(query, (DNS_SERVER, 53))
                # receive the response
                response, _ = s.recvfrom(1024)
                response = message.from_wire(response)
                assert response is not None
                # close the socket
                s.close()
                # list to store the result samples
                samples = list()
                for _ in range(NO_OF_SAMPLES):
                    outlier = True
                    while outlier:
                        # print(f"domain: {qname}")
                        # create a socket
                        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
                        # get timestamp before making request
                        ts_before = time.time_ns()
                        # request domain for test
                        query = message.make_query(qname, qtype).to_wire()
                        s.sendto(query, (DNS_SERVER, 53))
                        # receive the response
                        response, _ = s.recvfrom(1024)
                        response = message.from_wire(response)
                        # print(response.__str__())
                        assert response is not None
                        # close the socket
                        s.close()
                        # get timestamp after making request
                        ts_after = time.time_ns()
                        response_time = (ts_after - ts_before) / 1000000
                        # print(f"response time: {response_time}")
                        # print("------------------------")
                        # pdb.set_trace()
                        if response_time < OUTLIER_THRESHOLD:
                            # append current response time to samples list
                            samples.append(response_time)
                            outlier = False
                        else:
                            # track the outlier
                            outliers.append(f"ns:{ns['name']}, qname:{qname}, qtype:{qtype}, time(ms):{round(response_time, 2)}")
                # populate the metric lists with samples for the current response time
                domain_results_avg.append(statistics.mean(samples))
                domain_results_med.append(statistics.median(samples))
                domain_results_95th.append(np.percentile(np.array(samples), 95))
            # add the metrics for each nameserver to metric dicts for the current domain
            data_avg[domain] = domain_results_avg
            data_med[domain] = domain_results_med
            data_95th[domain] = domain_results_95th
        # extract the nameserver names from the nameserver dictionary
        ns_names = [ns['name'] for ns in nameservers]
        # create a pandas dataframe for each metrics
        df_avg = pd.DataFrame.from_dict(data_avg, orient="index", columns=ns_names)
        df_med = pd.DataFrame.from_dict(data_med, orient="index", columns=ns_names)
        df_95th = pd.DataFrame.from_dict(data_95th, orient="index", columns=ns_names)
        # print results
        metrics_data = {'AVERAGE': df_avg, 'MEDIAN': df_med, '95th': df_95th}
        df_summary = pd.DataFrame(columns=list(metrics_data.keys()), index=ns_names)
        for key, value in metrics_data.items():
            print("-" * 27)
            print(f"{key} RESPONSE TIMES (ms)")
            print("-" * 27)
            print(value.round(2))
            print(f"(Each domain was requested {NO_OF_SAMPLES} times per nameserver)")
            for ns in nameservers:
                df_summary.loc[ns['name']][key] = value[ns['name']].mean().round(2)

            print('\n')

        print("-" * 27)
        print("FRAMED MEANS OF METRICS FOR NAMESERVERS")
        print("-" * 27)
        print(df_summary)

        print('\n')

        print("-" * 33)
        print("OUTLIERS (EXCLUDED FROM AVERAGES)")
        print("-" * 33)
        [print(ol) for ol in outliers] if outliers else print("N/A")


if __name__ == "__main__":
    main()
