environments = [
    "dev",
    "test",
]

class EnvironmentConfig:
    HOST = "host...url"
    DATA_FILE = "data_file.txt"

class DevConfig(EnvironmentConfig):
    HOST = ""

class TestConfig(EnvironmentConfig):
    HOST = ""





