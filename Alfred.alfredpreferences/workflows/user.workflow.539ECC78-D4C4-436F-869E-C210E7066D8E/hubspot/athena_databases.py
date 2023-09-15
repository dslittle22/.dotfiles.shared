from tool import Tool
from utils import fetch

ATHENA_DATABASES_API_URL = "https://private.hubteam.com/minerva-janus/v1/getAllDatabases"
ATHENA_DATABASE_URL = "https://private.hubteam.com/athena/?database=%s"

class AthenaDatabases(Tool):
    def __init__(self, wf, auth, args):
        super(AthenaDatabases, self).__init__(wf)
        self.cache_key = "athena-databases"
        self.auth = auth

    def get_all_athena_databases(self, clear=False):
        return self.get(
            self.cache_key,
            ATHENA_DATABASES_API_URL,
            headers=self.auth.prodlogin_headers(clear=clear),
        )

    def list_all(self):
        return fetch(self.get_all_athena_databases)

    def to_item(self, athena_database):
        return dict(
            title=athena_database,
            arg=ATHENA_DATABASE_URL % athena_database,
            icon="icons/athena.png",
            uid=athena_database,
            valid=True,
        )

    def empty_result(self):
        return [
            dict(
                title="Athena Databases",
                subtitle="No Athena databases found with that name",
                icon="icons/athena.png",
                valid=False,
            )
        ]
