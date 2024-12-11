# Copyright © 2024 Dmitry Stoletov <info@imega.ru>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

dev:
	@docker compose up -d

stop:
	@-docker compose down -v --remove-orphans

gen: $(CURDIR)/prometheus/data
	@docker run --rm -t -v $(CURDIR)/prometheus/data:/data -w /data \
		-v $(CURDIR)/faker.sh:/usr/local/bin/faker.sh \
		bash \
		faker.sh
	@docker run --rm -t -v $(CURDIR)/prometheus/data:/data -w /data \
		--entrypoint=promtool \
		prom/prometheus:v2.38.0 \
			tsdb create-blocks-from \
			--max-block-duration=240h \
			openmetrics output.txt .

$(CURDIR)/prometheus/data:
	@mkdir -p $(CURDIR)/prometheus/data
