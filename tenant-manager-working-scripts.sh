################################
# ICICI HFC UTILS and LCNC Deployment Scripts
################################

###################
### Connect engine
###################

sudo docker stop connect-engine || true
sudo docker rm connect-engine || true

docker run -d \
  --name connect-engine \
  --restart unless-stopped \
  -p 6101:8002 \
  --dns 10.51.1.57 \
  --dns 10.78.28.82 \
  -e DATABASE_URL='mssql+pyodbc://LOSUAT:losuat_123@10.74.50.16,2580/uncia_connect?driver=ODBC+Driver+18+for+SQL+Server&TrustServerCertificate=yes' \
  -e DATABASE_SCHEMA='dbo' \
  -e LOG_LEVEL='INFO' \
  -e SCRIPT_TIMEOUT='10' \
  -e REQUEST_TIMEOUT='30' \
  -e KAFKA_BOOTSTRAP_SERVERS='' \
  -e KAFKA_LOG_TOPIC='connect-engine-api-logs-icici' \
  -e KAFKA_CONSUMER_GROUP='connect-engine-log-consumers-icici' \
  -e KAFKA_AUTO_OFFSET_RESET='earliest' \
  -e KAFKA_BATCH_SIZE='100' \
  -e KAFKA_BATCH_TIMEOUT='5.0' \
  -e ENDPOINT_CACHE_TTL='300' \
  -e ENABLE_ENDPOINT_CACHE='true' \
  -e ENDPOINT_CACHE_ENABLED='true' \
  -e TENANT_VAR_CACHE_TTL='300' \
  -e ENABLE_ASYNC_LOGGING='false' \
  -e MAX_SCRIPT_TIMEOUT='10' \
  -e HTTP_POOL_MAX_CONNECTIONS='200' \
  -e HTTP_POOL_MAX_KEEPALIVE='80' \
  -e HTTP_ENABLE_CONNECT_RETRY='false' \
  -e OTEL_ENABLED='false' \
  -e OTEL_SERVICE_NAME='connect-engine' \
  -e OTEL_EXPORTER_ENDPOINT='10.9.129.71:4317' \
  -e HTTP_CONCURRENT_PER_WORKER='50' \
  -e AWS_ACCESS_KEY_ID='' \
  -e AWS_SECRET_ACCESS_KEY='' \
  -e AWS_REGION='' \
  -e S3_BUCKET_NAME='' \
  -e S3_CERT_PREFIX='certs/' \
  -e CERT_ENCRYPTION_KEY='' \
  180294195647.dkr.ecr.ap-south-1.amazonaws.com/uncia/unciaprime:ENGINE-8d5fcb5c

# =========================
# UAM Frontend
# =========================
sudo docker stop uam-frontend || true
sudo docker rm uam-frontend || true

sudo docker run -d \
  --name uam-frontend \
  --restart unless-stopped \
  -p 6102:80 \
  -e REACT_APP_API_URL='https://veloctsandbox.icicihfc.com/useraccessbe/' \
  -e UAM_BACKEND_URL='https://veloctsandbox.icicihfc.com/useraccessbe/' \
  -e REACT_APP_UAM_D_URL='https://veloctsandbox.icicihfc.com/uam/' \
  -e REACT_APP_CONNECT_URL='https://veloctsandbox.icicihfc.com/connectfe/' \
  -e REACT_APP_CONNECT_BACKEND_URL='https://veloctsandbox.icicihfc.com/connectbe/' \
  -e PUBLIC_URL='/uam' \
  180294195647.dkr.ecr.ap-south-1.amazonaws.com/uncia/unciaprime:useraccess-fe-b8bb6b3a

#####
# UAM BE
#####
  
sudo docker stop uam-backend || true
sudo docker rm uam-backend || true

docker run -d \
  --name uam-backend \
  --restart unless-stopped \
  -p 6103:8000 \
  -e DATABASE_URL='mssql+pyodbc://unmuat:Connection%40123@10.74.50.16,2580/uamuat?driver=ODBC+Driver+18+for+SQL+Server&TrustServerCertificate=yes' \
  -e DATABASE_SCHEMA='dbo' \
  -e SECRET_KEY='your-super-secret-jwt-key-change-this-in-production-make-it-long-and-random' \
  -e ENCRYPTION_KEY='KjXE2TIlVzwgLvo6vou8x91-ylBaLXDtoC8969Wxn5I=' \
  -e ALGORITHM='HS256' \
  -e ACCESS_TOKEN_EXPIRE_MINUTES='5' \
  -e APP_HOST='0.0.0.0' \
  -e APP_PORT='8000' \
  -e DEBUG='true' \
  -e FRONTEND_URL='https://hfclosuat.icicihfc.com' \
  -e UAM_BACKEND_URL='https://veloctsandbox.icicihfc.com/useraccessbe/' \
  -e REACT_APP_CONNECT_URL='https://veloctsandbox.icicihfc.com/connectfe/' \
  -e REACT_APP_UAM_D_URL='https://veloctsandbox.icicihfc.com/uam/' \
  -e REACT_APP_HOST_URL='https://veloctsandbox.icicihfc.com/main' \
  -e CONTEXT_PATH='/useraccessbe' \
  -e CORS_ORIGINS='https://unciaflow-icici.uncia.ai,http://10.9.129.71:3000,http://10.9.129.71:444,http://veloctlcnc.icicihfc.com,http://veloctlcnc.icicihfc.com:6120,veloctsandbox.icicihfc.com' \
  -e LOG_LEVEL='INFO' \
  -e LOG_FILE='app.log' \
  -e REDIS_HOST='10.9.129.71' \
  -e REDIS_PORT='6110' \
  -e REDIS_ENABLED='false' \
  -e REDIS_DB='0' \
  -e SMTP_HOST='' \
  -e SMTP_PORT='' \
  -e SMTP_USER='' \
  -e SMTP_PASSWORD='' \
  -e SMTP_FROM='' \
  -e FROM_EMAIL='' \
  -e FROM_NAME='UNCIA Connect' \
  -e EMAIL_ENABLED='false' \
  -e KAFKA_ENABLED='false' \
  -e KAFKA_BOOTSTRAP_SERVERS='' \
  -e KAFKA_UAM_CONSUMER_GROUP='uam-notification-consumer-icici' \
  -e KAFKA_CONSUMER_GROUP='connect-clone-consumer-icici' \
  -e KAFKA_TOPIC_TENANT_CREATED='uam.tenant.created-icici' \
  -e KAFKA_TOPIC_CLONE_STARTED='connect.clone.started-icici' \
  -e KAFKA_TOPIC_CLONE_COMPLETED='connect.clone.completed-icici' \
  -e KAFKA_TOPIC_CLONE_FAILED='connect.clone.failed-icici' \
  -e MAX_FILE_SIZE='10485760' \
  -e UPLOAD_DIRECTORY='uploads' \
  -e BCRYPT_ROUNDS='12' \
  -e SESSION_TIMEOUT='1800' \
  -e LOGIN_RATE_LIMIT='5' \
  -e API_RATE_LIMIT='100' \
  180294195647.dkr.ecr.ap-south-1.amazonaws.com/uncia/unciaprime:useraccess-be-0a0df2ae

# =========================
# Datamapper-Frontend
# =========================

sudo docker stop datamapper-frontend || true
sudo docker rm datamapper-frontend || true

sudo docker run -d \
  --name datamapper-frontend \
  --restart unless-stopped \
  -p 6106:3011 \
  180294195647.dkr.ecr.ap-south-1.amazonaws.com/uncia/unciaprime:requesmapper-fe-8adc4dd1


# =========================
# Datamapper-Backend
# =========================
sudo docker stop datamapper-backend || true
sudo docker rm datamapper-backend || true

sudo docker run -d \
  --name datamapper-backend \
  --restart unless-stopped \
  -p 6107:8012 \
  -p 6108:8013 \
  180294195647.dkr.ecr.ap-south-1.amazonaws.com/uncia/unciaprime:requesmapper-be-31ad9d2a

# =========================
# Tenant Manager
# =========================
sudo docker stop tenant-manager || true
sudo docker rm tenant-manager || true

sudo docker run -d \
  --name tenant-manager \
  --restart unless-stopped \
  -p 6100:80 \
  -e PUBLIC_URL="/main" \
  -e REACT_APP_APIINIT_URL="" \
  -e REACT_APP_API_URL="https://veloctsandbox.icicihfc.com/useraccessbe/" \
  -e REACT_APP_CIPHER_URL="" \
  -e REACT_APP_CONNECT_URL="https://veloctsandbox.icicihfc.com/connectfe/" \
  -e REACT_APP_EMAIL_URL="" \
  -e REACT_APP_HEALTHCHECK_URL="" \
  -e REACT_APP_MAIN_URL="https://veloctsandbox.icicihfc.com/main" \
  -e REACT_APP_REQMAPPER_URL="https://veloctsandbox.icicihfc.com/requestmapfe/" \
  -e REACT_APP_SMS_URL="" \
  -e REACT_APP_UAM_D_URL="https://veloctsandbox.icicihfc.com/uam/" \
  -e REACT_APP_UAM_URL="https://veloctsandbox.icicihfc.com/uam/" \
  -e UAM_BACKEND_URL="https://veloctsandbox.icicihfc.com/useraccessbe/" \
  180294195647.dkr.ecr.ap-south-1.amazonaws.com/uncia/unciaprime:tenantmanger-85d2264b

# =========================
# Connect Frontend
# =========================
sudo docker stop connect-frontend || true
sudo docker rm connect-frontend || true


sudo docker run -d \
  --name connect-frontend \
  --restart unless-stopped \
  -p 6104:3002 \
  -e REACT_APP_BACKEND_URL='https://veloctsandbox.icicihfc.com/connectbe' \
  -e REACT_APP_CONNECT_URL='https://veloctsandbox.icicihfc.com/connectfe/' \
  -e REACT_APP_CONNECT_ENGINE_URL='https://veloctsandbox.icicihfc.com/engine/connect/api/call' \
  -e PUBLIC_URL='/connectfe' \
  -e NODE_ENV='production' \
  180294195647.dkr.ecr.ap-south-1.amazonaws.com/uncia/unciaprime:connect-fe-181cb201

# ########################
# Connect Backend
# ########################

sudo docker stop connect-backend || true
sudo docker rm connect-backend || true

sudo docker run -d \
  --name connect-backend \
  --restart unless-stopped \
  -p 6105:8001 \
  --dns 10.51.1.57 \
  --dns 10.78.28.82 \
  -e DATABASE_URL='mssql+pyodbc://uncia_connect:Connection%40123@10.74.50.16,2580/uncia_connect?driver=ODBC+Driver+18+for+SQL+Server&TrustServerCertificate=yes' \
  -e DATABASE_SCHEMA='dbo' \
  -e ENCRYPTION_KEY='...' \
  -e SECRET_KEY='...' \
  -e ALGORITHM='HS256' \
  -e ACCESS_TOKEN_EXPIRE_MINUTES='1440' \
  -e REQUIRE_AUTHENTICATION='false' \
  -e DEFAULT_TENANT_ID='1' \
  -e DEFAULT_TENANT_NAME='Default Tenant' \
  -e API_V1_STR='/api/v1' \
  -e PROJECT_NAME='UNCIA Connect API' \
  -e VERSION='1.0.0' \
  -e PORT='8001' \
  -e CONNECT_ENGINE_URL='https://veloctsandbox.icicihfc.com/engine/connect/api/call' \
  -e BACKEND_CORS_ORIGINS='https://hfclosuat.icicihfc.com' \
  -e ENVIRONMENT='development' \
  -e DEBUG='true' \
  -e LOG_LEVEL='INFO' \
  -e AI_DEDUPE_ENABLED='true' \
  -e AI_DEDUPE_SIMILARITY_THRESHOLD='80' \
  -e AI_DEDUPE_PATH_WEIGHT='40' \
  -e AI_DEDUPE_METHOD_WEIGHT='25' \
  -e AI_DEDUPE_NAME_WEIGHT='20' \
  -e AI_DEDUPE_PATTERN_WEIGHT='15' \
  -e ANTHROPIC_API_KEY='...' \
  -e LLM_ENABLED='true' \
  -e LLM_MODEL='claude-sonnet-4-20250514' \
  -e LLM_PREFILTER_THRESHOLD='50' \
  -e LLM_ALWAYS_RUN='true' \
  -e LLM_CACHE_TTL_MINUTES='60' \
  -e LLM_TIMEOUT_SECONDS='30' \
  -e LLM_LEARNING_ENABLED='true' \
  -e LLM_LEARNING_MIN_OVERRIDES='5' \
  -e REDIS_HOST='...' \
  -e REDIS_PORT='...' \
  -e REDIS_PASSWORD='...' \
  -e REDIS_DB='0' \
  -e KAFKA_ENABLED='false' \
  -e KAFKA_AUTO_OFFSET_RESET='earliest' \
  -e KAFKA_BOOTSTRAP_SERVERS='' \
  -e KAFKA_CONSUMER_GROUP='connect-clone-consumer-icici' \
  -e KAFKA_TOPIC_TENANT_CREATED='uam.tenant.created-icici' \
  -e KAFKA_TOPIC_CLONE_STARTED='connect.clone.started-icici' \
  -e KAFKA_TOPIC_CLONE_COMPLETED='connect.clone.completed-icici' \
  -e KAFKA_TOPIC_CLONE_FAILED='connect.clone.failed-icici' \
  -e UAM_WEBSOCKET_URL='https://veloctsandbox.icicihfc.com/useraccessbe' \
  -e SMTP_HOST='' \
  -e SMTP_PORT='0' \
  -e SMTP_USER='' \
  -e SMTP_PASSWORD='' \
  -e SMTP_FROM_EMAIL='' \
  -e AUDIT_LOG_ENABLED='false' \
  -e ELASTICSEARCH_URL='http://10.9.129.71:9200' \
  -e ELASTICSEARCH_AUDIT_INDEX='connect_audit_logs-icici' \
  -e AWS_ACCESS_KEY_ID='' \
  -e AWS_SECRET_ACCESS_KEY='' \
  -e AWS_REGION='' \
  -e S3_BUCKET_NAME='' \
  -e S3_CERT_PREFIX='certs/' \
  -e CERT_ENCRYPTION_KEY='' \
  180294195647.dkr.ecr.ap-south-1.amazonaws.com/uncia/unciaprime:connect-be-a6597afd

##############
# LCNC / JW
##############

sudo docker stop lcnc || true
sudo docker rm lcnc || true

sudo docker run -d \
  --name lcnc \
  --restart unless-stopped \
  -p 6109:8080 \
  --dns 10.51.1.57 \
  --dns 10.78.28.82 \
  -e DB_DRIVER="com.microsoft.sqlserver.jdbc.SQLServerDriver" \
  -e LCNC_DB_URL="jdbc:sqlserver://10.74.50.16:2580;databaseName=UCPrimejw;encrypt=true;trustServerCertificate=true" \
  -e UDS_DB_URL="jdbc:sqlserver://10.74.50.16:2580;databaseName=UCPrimeUDS;encrypt=true;trustServerCertificate=true" \
  -e DB_USER="LOSUAT" \
  -e DB_PASSWORD="losuat_123" \
  -e UDS_DB_DIALECT="org.hibernate.dialect.SQLServerDialect" \
  -e DS_MAX_TOTAL="100" \
  -e DS_MAX_IDLE="30" \
  -e DS_MIN_IDLE="10" \
  -e MAX_FILE_COUNT="500" \
  -e LCNC_TOMCAT_MAX_THREADS="100" \
  -e LCNC_TOMCAT_MIN_SPARE_THREADS="20" \
  -e LCNC_TOMCAT_ACCEPT_COUNT="200" \
  -e LCNC_TOMCAT_MAX_CONNECTIONS="2000" \
  -e LCNC_APIPLUGIN_READ_TIMEOUT_MS="12000" \
  -e LCNC_APIPLUGIN_CONNECT_TIMEOUT_MS="5000" \
  -e LCNC_CACHE_USERVIEW_ENTRIES="3000" \
  -e LCNC_CACHE_FLU_ENTRIES="10000" \
  -e LCNC_CACHE_FORM_OPTIONS_ENTRIES="3000" \
  -e WFLOW_HOME="/opt/lcnc/wflow" \
  -e JAVA_OPTS="-Xms1024M -Xmx2560M -Xss512k -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:MaxMetaspaceSize=384m -XX:ReservedCodeCacheSize=128m -XX:+ParallelRefProcEnabled -XX:+ExitOnOutOfMemoryError -Dwflow.home=/opt/lcnc/wflow -Dlcnc.mcp.context.path=/jw" \
  -e LCNC_COPILOT_ENABLED="false" \
  -e ANTHROPIC_API_KEY="REPLACE_ME" \
  -e DESIGN_API_KEY="REPLACE_ME" \
  -e LCNC_MCP_EXTERNAL_ENABLED="false" \
  -e LCNC_MCP_API_KEY="REPLACE_ME" \
  -e LCNC_MCP_ALLOWED_CIDRS="REPLACE_ME" \
  -e LCNC_MCP_TRUST_XFF="true" \
  -e LCNC_MCP_DEBUG_HEADERS="false" \
  180294195647.dkr.ecr.ap-south-1.amazonaws.com/uncia/unciaprime:UP-LCNCUPGRADE-0cd6142d

######################
# UPAPI
######################

sudo docker stop upapi || true
sudo docker rm upapi || true

docker run -d \
  --name upapi \
  --restart unless-stopped \
  -p 6111:8080 \
  --dns 10.51.1.57 \
  --dns 10.78.28.82 \
  -e dms.endpoint="" \
  -e dms.uploadservice="" \
  -e dms.fiid="" \
  -e dms.finame="" \
  -e dms.token="" \
  -e dms.user="" \
  -e dms.api-key="" \
  -e storage.local-storage-enabled="true" \
  -e storage.local-storage-path="/tmp/upapi-localstorage" \
  180294195647.dkr.ecr.ap-south-1.amazonaws.com/uncia/unciaprime:UPAPI-d58a8e77


########
# Nginx run
########

  docker run -d \
  --name icici-nginx-web \
  --restart unless-stopped \
  -p 444:444 \
  icici-web:v11

##############
# Nginx image build 
##############

docker build -t icici-web:v17 .

###########
# NGINX HTTP DOMAIN 
###########

  docker run -d \
  --name icici-nginx-web \
  --restart unless-stopped \
  -p 80:80 \
  icici-web:v11
