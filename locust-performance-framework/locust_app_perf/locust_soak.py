from locust import between
from locust_user import AppUser
from test_config import TestConfig

global_config = TestConfig.global_config

class SoakDo53UserNoBlocks(AppUser):
    weight = 1
    wait_time = between(7, 13)
    data_file = global_config.DATA_FILE


class SoakTCPUserNoBlocks(AppUser):
    pass


