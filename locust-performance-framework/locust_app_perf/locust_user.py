from locust import TaskSet, task, User, events, between
from test_config import TestConfig

global_config = TestConfig.global_config

class AppTasks(TaskSet):
    def on_start(self):
        # You can read the data here (i.e. from a data file)
        pass

    @task
    def your_query(self):
        # define the task here (i.e. make a http request)
        pass

class AppUser(User):
    abstract = True
    def __init__(self, parent):
        super().__init__(parent)

    host = str(global_config.HOST)
    tasks = [AppTasks]


