import os
from environment_config import (
    environments,
    EnvironmentConfig,
    DevConfig,
    TestConfig,
)
from pathlib import Path

target_env = os.environ.get('TARGET_ENV')
if target_env not in environments:
    print('Invalid TARGET_ENV environment variable: %s. Valid values: %s' % (target_env, ','.join(environments)))
    exit()

# Load the target environment config
env_file = Path(f"environment_config/{target_env}.json")
print(f"Environment file: {env_file}")
if "dev" in target_env:
    env_config = DevConfig.parse_file(env_file)
elif "test" in target_env:
    env_config = TestConfig.parse_file(env_file)
else:
    env_config = EnvironmentConfig.parse_file(env_file)

# Print out the environment settings to the console for reference
print("Environment Settings:")
print("\n".join(env_config.__str__().split()))

class TestConfig(object):
    global_config = env_config




