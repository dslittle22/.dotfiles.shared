import urllib

from tool import Tool
from utils import fetch

HBASE_TABLES_API_URL = "https://private.hubteam%s.com/genesis/v1/table-finder?tableNameContains=%s"
HBASE_TABLES_URL = "https://private.hubteam.com/hbase/clusters/%s/%s/%s"

class HbaseTables(Tool):
    def __init__(self, env, cache_key, wf, auth, args):
        super(HbaseTables, self).__init__(wf)
        self.env = env
        self.api_env = ("qa" if self.env == "qa" else "")
        self.cache_key = cache_key
        self.auth = auth

    def list_all(self):
        return [
            dict(
                full_name="HBase Tables", language="Start typing a HBase table name", valid=False
            )
        ]

    def filter(self, results, args):
        def get(clear=False):
            if args and len(args) and len(args[0].strip()):
                search = " ".join(args)
                search = urllib.quote(search)
                response =  self.get(
                    "hbase-tables-%s-%s" % (self.env, search),
                    HBASE_TABLES_API_URL % (self.api_env, search),
                    headers=self.auth.prodlogin_headers(clear=clear),
                    )

                return response['results']
            else:
                return []

        return fetch(get)

    def to_item(self, hbase_table):
        return dict(
            title=hbase_table.get("tableName"),
            arg=HBASE_TABLES_URL % (self.env, urllib.quote(hbase_table.get("clusterName")), urllib.quote(hbase_table.get("tableName"))),
            icon="icons/hbase.png",
            uid=hbase_table.get("tableName"),
            valid=True,
        )

    def empty_result(self):
        return [
            dict(
                title="HBase Tables" + (" (QA)" if self.env == "qa" else ""),
                subtitle="No HBase tables found with that name",
                icon="icons/hbase.png",
                valid=False,
            )
        ]

class HbaseTablesPROD(HbaseTables):
    def __init__(self, *args):
        super(HbaseTablesPROD, self).__init__("prod", "hbase-tables-prod", *args)


class HbaseTablesQA(HbaseTables):
    def __init__(self, *args):
        super(HbaseTablesQA, self).__init__("qa", "hbase-tables-qa", *args)
