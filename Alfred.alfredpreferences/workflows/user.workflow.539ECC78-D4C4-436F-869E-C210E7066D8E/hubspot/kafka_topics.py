import urllib

from tool import Tool
from utils import fetch

KAFKA_TOPICS_API_URL = "https://private.hubteam%s.com/kafka-janus/v1/topics"
KAFKA_TOPIC_URL = "https://private.hubteam.com/kafka/clusters/%s/%s/topics/%s"

class KafkaTopics(Tool):
    def __init__(self, env, cache_key, wf, auth, args):
        super(KafkaTopics, self).__init__(wf, ["name"])
        self.env = env
        self.api_env = ("qa" if self.env == "qa" else "")
        self.cache_key = cache_key
        self.auth = auth

    def get_all_kafka_topics(self, clear=False):
        return self.get(
            self.cache_key,
            KAFKA_TOPICS_API_URL % self.api_env,
            auth=self.auth.okta(self.env, clear),
        )

    def list_all(self):
        return fetch(self.get_all_kafka_topics)

    def to_item(self, kafka_topic):
        return dict(
            title=kafka_topic.get("name"),
            arg=KAFKA_TOPIC_URL % (self.env, urllib.quote(kafka_topic.get("clusterName")), urllib.quote(kafka_topic.get("name"))),
            icon="icons/kafka.png",
            uid=kafka_topic.get("name"),
            valid=True,
        )

    def empty_result(self):
        return [
            dict(
                title="Kafka Topics" + (" (QA)" if self.env == "qa" else ""),
                subtitle="No Kafka topics found with that name",
                icon="icons/kafka.png",
                valid=False,
            )
        ]


class KafkaTopicsPROD(KafkaTopics):
    def __init__(self, *args):
        super(KafkaTopicsPROD, self).__init__("prod", "kafka-topics-prod", *args)


class KafkaTopicsQA(KafkaTopics):
    def __init__(self, *args):
        super(KafkaTopicsQA, self).__init__("qa", "kafka-topics-qa", *args)
