import urllib

from tool import Tool
from utils import fetch

VITESS_KEYSPACES_API_URL = "https://private.hubteam%s.com/vitessez/v1/keyspaceshards"
VITESS_KEYSPACES_URL = "https://private.hubteam%s.com/vitess/keyspaces/%s"

class VitessKeyspaces(Tool):
    def __init__(self, env, cache_key, wf, auth, args):
        super(VitessKeyspaces, self).__init__(wf, ["spec.keyspace"])
        self.env = env
        self.cache_key = cache_key
        self.auth = auth

    def get_all_vitess_keyspaces(self, clear=False):
        return self.get(
            self.cache_key,
            VITESS_KEYSPACES_API_URL % self.env,
            headers=self.auth.prodlogin_headers(clear=clear),
        )

    def list_all(self):
        return fetch(self.get_all_vitess_keyspaces)

    def to_item(self, vitess_keyspace):
        return dict(
            title=vitess_keyspace.get("spec").get("keyspace"),
            arg=VITESS_KEYSPACES_URL % (self.env, urllib.quote(vitess_keyspace.get("spec").get("keyspace"))),
            icon="icons/vitess.png",
            uid=vitess_keyspace.get("spec").get("keyspace"),
            valid=True,
        )

    def empty_result(self):
        return [
            dict(
                title="Vitess Keyspaces" + (" (QA)" if self.env == "qa" else ""),
                subtitle="No Vitess keyspaces found with that name",
                icon="icons/vitess.png",
                valid=False,
            )
        ]


class VitessKeyspacesPROD(VitessKeyspaces):
    def __init__(self, *args):
        super(VitessKeyspacesPROD, self).__init__("", "vitess-keyspaces-prod", *args)


class VitessKeyspacesQA(VitessKeyspaces):
    def __init__(self, *args):
        super(VitessKeyspacesQA, self).__init__("qa", "vitess-keyspaces-qa", *args)
