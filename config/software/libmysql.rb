#
# Copyright 2013, Craig Tracey <craigtracey@gmail.com>
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
#
name    "libmysql"
version "6.1.0"

source  :url => "http://mirror.cogentco.com/pub/mysql/Connector-C/mysql-connector-c-#{version}-src.tar.gz",
  :md5 => "02b8cb2bdc2ca281d3d87b0ab8d719c4"

relative_path "mysql-connector-c-#{version}-src"

env = {
  "LD_RUN_PATH" => "#{install_dir}/embedded/lib",
}

build do
  command "cmake -DCMAKE_INSTALL_PREFIX=#{install_dir}/embedded .", :env => env
  command "make install"
end