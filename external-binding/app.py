#
# Copyright 2021 The Dapr Authors
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#     http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# dapr run --app-id batch-http --app-port 50051
#   --resources-path ../../../components -- python3 app.py

import json
from flask import Flask
import requests
import os

app = Flask(__name__)

# app_port = '5002'
app_port = os.getenv('APP_PORT')
dapr_port = os.getenv('DAPR_HTTP_PORT')
base_url = os.getenv('BASE_URL', 'http://localhost')
cron_binding_name = 'cron'
sql_binding_name = 'sqldb'
dapr_url = '%s:%s/v1.0/bindings/%s' % (base_url,
                                       dapr_port,
                                       sql_binding_name)


# Triggered by Dapr input binding
@app.route('/' + cron_binding_name, methods=['POST'])
def process_batch():

    print('Processing batch..', flush=True)

    print('Finished processing batch', flush=True)

    return json.dumps({'success': True})


app.run(port=app_port)
