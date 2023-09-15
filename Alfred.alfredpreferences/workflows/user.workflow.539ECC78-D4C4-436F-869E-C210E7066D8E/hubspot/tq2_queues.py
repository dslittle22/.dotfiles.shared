import urllib

from tool import Tool
from utils import fetch

TQ2_QUEUES_API_URL = "https://private.hubteam%s.com/tq2-visibility/v1/queues-janus/with-write/metadata"
TQ2_QUEUES_URL = "https://private.hubteam.com/tq2/queues/%s/%s"

class Tq2Queues(Tool):
    def __init__(self, env, cache_key, wf, auth, args):
        super(Tq2Queues, self).__init__(wf, ["name"])
        self.env = env
        self.api_env = ("qa" if self.env == "qa" else "")
        self.cache_key = cache_key
        self.auth = auth

    def get_all_tq2_queues(self, clear=False):
        return self.get(
            self.cache_key,
            TQ2_QUEUES_API_URL % self.api_env,
            headers=self.auth.prodlogin_headers(clear=clear),
        )

    def list_all(self):
        return fetch(self.get_all_tq2_queues)

    def to_item(self, tq2_queue):
        return dict(
            title=tq2_queue.get("name"),
            arg=TQ2_QUEUES_URL % (self.env, urllib.quote(tq2_queue.get("name"))),
            icon="icons/tq2.png",
            uid=tq2_queue.get("name"),
            valid=True,
        )

    def empty_result(self):
        return [
            dict(
                title="TQ2 Queues" + (" (QA)" if self.env == "qa" else ""),
                subtitle="No TQ2 queues found with that name",
                icon="icons/tq2.png",
                valid=False,
            )
        ]


class Tq2QueuesPROD(Tq2Queues):
    def __init__(self, *args):
        super(Tq2QueuesPROD, self).__init__("prod", "tq2-queues-prod", *args)


class Tq2QueuesQA(Tq2Queues):
    def __init__(self, *args):
        super(Tq2QueuesQA, self).__init__("qa", "tq2-queues-qa", *args)
