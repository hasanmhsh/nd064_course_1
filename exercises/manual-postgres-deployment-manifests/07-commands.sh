
#Open psql to pstgresql
kubectl exec -it postgresPodName -- psql -h localhost -U postgres --password -p 5432 chattranslationdb3

#Restore database file to postgres deployment
kubectl exec -it postgres-85c5cb6c44-sc4bf -- psql -h localhost -U postgres --password -p 5432 chattranslationdb3 < ../chattranslationdb3.sql

#Backup database from postgresql db pod into file 
	# 1-Open interactive shell to the pod
	kubectl exec -it ${POD_NAME} /bin/sh
	kubectl exec -it postgres-85c5cb6c44-sc4bf /bin/sh

	# 2-Dump(backup) the database in a file inside the pod
	pg_dump -U ${DB_USER} --format=p --file=pg_dump_backup.sql ${db_name}
	pg_dump -U postgres --format=p --file=pg_dump_backup.sql chattranslationdb3

	# 3-Remot copy the dumpfile from postgres pod to host os
	kubectl cp ${POD_NAME}:pg_dump_backup.sqlc ~/pg_dump_backup.sqlc
	kubectl cp postgres-85c5cb6c44-sc4bf:pg_dump_backup.sqlc ~/pg_dump_backup.sqlc



#Connect from outside the cluster from the host of the cluster
psql -h ${KUBERNETES_HOST_IP} -U appuser --password -p 31398 appdb
#31398 This port obtained by    kubectl get svc
