. utils/envVar.sh

#Color code for shell script
Red='\033[0;31m'
Green='\033[0;32m'
Color_Off='\033[0m'

pid_tlsca=$(lsof -i tcp:7054 | grep fabric-ca | awk '{print $2}')
pid_rca=$(lsof -i tcp:7055 | grep fabric-ca | awk '{print $2}')
pid_ica=$(lsof -i tcp:7056 | grep fabric-ca | awk '{print $2}')
pid_oca=$(lsof -i tcp:7057 | grep fabric-ca | awk '{print $2}')

if [ ! -z "$pid_tlsca" ]
then
    echo "TLSCA PID: " $pid_tlsca
    kill -9 $pid_tlsca
fi

if [ ! -z "$pid_rca" ]
then
    echo "RCA PID: " $pid_rca
    kill -9 $pid_rca
fi

if [ ! -z "$pid_ica" ]
then
    echo "ICA PID: " $pid_ica
    kill -9 $pid_ica
fi

if [ ! -z "$pid_oca" ]
then
    echo "OCA PID: " $pid_oca
    kill -9 $pid_oca
fi

echo "TLSCA PID: " $pid_tlsca
echo "RCA PID: " $pid_rca
echo "ICA PID: " $pid_ica
echo "OCA PID: " $pid_oca

sleep 2


#Deploy TLS CA Certificate Authority
sh utils/deployServer.sh fabric-ca-server-tls tls-admin tls-adminpw TLSCA & 

sleep 2

# Enroll TLS CA admin user generates TLS root certificate for TLS CA
sh utils/enrollAdminUser.sh tls-admin tls-adminpw TLSCA 7054 TLS tls-root-cert/tls-ca-cert.pem 'host1,localhost'

# This command will register Organization CA of Super Admin to TLS CA.
sh utils/registerAdminUser.sh rca-o1-super-admin-bta-kilroy Rca-O1-Super-Admin-Bta-Kilroy 7054 tls-root-cert/tls-ca-cert.pem tls-ca/tls-admin/msp RCA

#This command will enroll the Organization CA of Super Admin i.e it will generate TLS certificate for Organization CA of Super Admin
sh utils/enrollAdminUser.sh rca-o1-super-admin-bta-kilroys Rca-O1-Super-Admin-Bta-Kilroy RCA 7054 TLS tls-root-cert/tls-ca-cert.pem 'host1,localhost' 

# This command will register Intermediate CA of Super Admin to TLS CA.
sh utils/registerAdminUser.sh ica-o1-super-admin-bta-kilroy Ica-O1-Super-Admin-Bta-Kilroy 7054 tls-root-cert/tls-ca-cert.pem tls-ca/tls-admin/msp RCA

# This command will enroll the Intermediate CA of Super Admin i.e it will generate TLS certificate for Intermediate CA of Super Admin
sh utils/enrollAdminUser.sh ica-o1-super-admin-bta-kilroy Ica-O1-Super-Admin-Bta-Kilroy RCA 7054 TLS tls-root-cert/tls-ca-cert.pem 'host1,localhost'

# This command will run Organization CA server of Super Admin. 
sh utils/deployServer.sh rca-o1-super-admin-bta-kilroy-server rca-o1-super-admin-bta-kilroy Rca-O1-Super-Admin-Bta-Kilroy RCA 7055 fabric-ca-client 127.0.0.1:9444 & 

sleep 2

# This command will enroll the Organization CA of Super Admin i.e it will generate Enrollment certificate for Organization CA of Super Admin 
sh utils/enrollAdminUser.sh rca-o1-super-admin-bta-kilroy Rca-O1-Super-Admin-Bta-Kilroy RCA 7055 RCA tls-root-cert/tls-ca-cert.pem 'host1,localhost'

# This command will register Intermediate CA of Super Admin to Organization CA.
sh utils/registerAdminUser.sh ica-o1-super-admin-bta-kilroy Ica-O1-Super-Admin-Bta-Kilroy 7055 tls-root-cert/tls-ca-cert.pem org-ca/rca-o1-super-admin-bta-kilroy/msp ICA

# This command will run Intermediate CA server of Super Admin. 
sh utils/deployServer.sh ica-o1-super-admin-bta-kilroy-server ica-o1-super-admin-bta-kilroy Ica-O1-Super-Admin-Bta-Kilroy ICA 7056 fabric-ca-client 127.0.0.1:9445 fabric-ca-server-tls rca-o1-super-admin-bta-kilroy Rca-O1-Super-Admin-Bta-Kilroy 7055 & 

sleep 2

sh utils/enrollAdminUser.sh ica-o1-super-admin-bta-kilroy Ica-O1-Super-Admin-Bta-Kilroy RCA 7056 RCA tls-root-cert/tls-ca-cert.pem 'host1,localhost'

sh utils/registerNodeAdminTLS.sh peer Peer-Admin-Pw 7054 tls-root-cert/tls-ca-cert.pem tls-ca/tls-admin/msp/ PEER_ADMIN o1-super-admin bta.kilroy

sh utils/registerNode.sh peer Peer-Admin-Pw 7056 tls-root-cert/tls-ca-cert.pem org-ca/ica-o1-super-admin-bta-kilroy/msp/ PEER_ADMIN o1-super-admin bta.kilroy

sh utils/enrollNode.sh peer Peer-Admin-Pw o1-super-admin 7054 TLS tls-root-cert/tls-ca-cert.pem "localhost,*.o1-super-admin.bta.kilroy" PEER_ADMIN bta.kilroy

sh utils/enrollNode.sh peer Peer-Admin-Pw o1-super-admin 7056 RCA tls-root-cert/tls-ca-cert.pem 'localhost,*.o1-super-admin.bta.kilroy' PEER_ADMIN bta.kilroy


sh utils/registerNode.sh peer0 Peer-O1-SuperAdmin-Pw 7054 tls-root-cert/tls-ca-cert.pem tls-ca/tls-admin/msp/ PEER o1-super-admin bta.kilroy

sh utils/registerNode.sh peer0 Peer-O1-SuperAdmin-Pw 7056 tls-root-cert/tls-ca-cert.pem org-ca/ica-o1-super-admin-bta-kilroy/msp/ PEER o1-super-admin bta.kilroy

sh utils/enrollNode.sh peer0 Peer-O1-SuperAdmin-Pw o1-super-admin 7054 TLS tls-root-cert/tls-ca-cert.pem "localhost,*.o1-super-admin.bta.kilroy" PEER bta.kilroy

sh utils/enrollNode.sh peer0 Peer-O1-SuperAdmin-Pw o1-super-admin 7056 RCA tls-root-cert/tls-ca-cert.pem "localhost,*.o1-super-admin.bta.kilroy" PEER bta.kilroy

sleep 2
#SUPER ADMIN ENDS------

pid_rca=$(lsof -i tcp:7055 | grep fabric-ca | awk '{print $2}')
pid_ica=$(lsof -i tcp:7056 | grep fabric-ca | awk '{print $2}')

echo "RCA PID: " $pid_rca
echo "ICA PID: " $pid_ica

kill -9 $pid_rca

kill -9 $pid_ica

sleep 2

#Company ADMIN STARTS------

sh utils/registerAdminUser.sh rca-o2-admin-bta-kilroy Rca-O2-Admin-Bta-Kilroy 7054 tls-root-cert/tls-ca-cert.pem tls-ca/tls-admin/msp RCA

sh utils/enrollAdminUser.sh rca-o2-admin-bta-kilroy Rca-O2-Admin-Bta-Kilroy RCA 7054 TLS tls-root-cert/tls-ca-cert.pem 'host1,localhost'

sh utils/registerAdminUser.sh ica-o2-admin-bta-kilroy Ica-O2-Admin-Bta-Kilroy 7054 tls-root-cert/tls-ca-cert.pem tls-ca/tls-admin/msp RCA

sh utils/enrollAdminUser.sh ica-o2-admin-bta-kilroy Ica-O2-Admin-Bta-Kilroy RCA 7054 TLS tls-root-cert/tls-ca-cert.pem 'host1,localhost'

sh utils/deployServer.sh rca-o2-admin-bta-kilroy-server rca-o2-admin-bta-kilroy Rca-O2-Admin-Bta-Kilroy RCA 7055 fabric-ca-client 127.0.0.1:9444 & 

sleep 2

sh utils/enrollAdminUser.sh rca-o2-admin-bta-kilroy Rca-O2-Admin-Bta-Kilroy RCA 7055 RCA tls-root-cert/tls-ca-cert.pem 'host1,localhost'

sh utils/registerAdminUser.sh ica-o2-admin-bta-kilroy Ica-O2-Admin-Bta-Kilroy 7055 tls-root-cert/tls-ca-cert.pem org-ca/rca-o2-admin-bta-kilroy/msp ICA

sh utils/deployServer.sh ica-o2-admin-bta-kilroy-server ica-o2-admin-bta-kilroy Ica-O2-Admin-Bta-Kilroy ICA 7056 fabric-ca-client 127.0.0.1:9445 fabric-ca-server-tls rca-o2-admin-bta-kilroy Rca-O2-Admin-Bta-Kilroy 7055 & 

sleep 2

sh utils/enrollAdminUser.sh ica-o2-admin-bta-kilroy Ica-O2-Admin-Bta-Kilroy RCA 7056 RCA tls-root-cert/tls-ca-cert.pem 'host1,localhost'

# Peer Admin Starts
sh utils/registerNodeAdminTLS.sh peer Peer-Admin-Pw 7054 tls-root-cert/tls-ca-cert.pem tls-ca/tls-admin/msp/ PEER_ADMIN o2-admin bta.kilroy

sh utils/registerNode.sh peer Peer-Admin-Pw 7056 tls-root-cert/tls-ca-cert.pem org-ca/ica-o2-admin-bta-kilroy/msp/ PEER_ADMIN o2-admin bta.kilroy

sh utils/enrollNode.sh peer Peer-Admin-Pw o2-admin 7054 TLS tls-root-cert/tls-ca-cert.pem "localhost,*.o2-admin.bta.kilroy" PEER_ADMIN bta.kilroy

sh utils/enrollNode.sh peer Peer-Admin-Pw o2-admin 7056 RCA tls-root-cert/tls-ca-cert.pem 'localhost,*.o2-admin.bta.kilroy' PEER_ADMIN bta.kilroy

# Peer Admin Ends

# Peer Starts
sh utils/registerNode.sh peer0 Peer-O1-SuperAdmin-Pw 7054 tls-root-cert/tls-ca-cert.pem tls-ca/tls-admin/msp/ PEER o2-admin bta.kilroy

sh utils/registerNode.sh peer0 Peer-O1-SuperAdmin-Pw 7056 tls-root-cert/tls-ca-cert.pem org-ca/ica-o2-admin-bta-kilroy/msp/ PEER o2-admin bta.kilroy

sh utils/enrollNode.sh peer0 Peer-O1-SuperAdmin-Pw o2-admin 7054 TLS tls-root-cert/tls-ca-cert.pem "localhost,*.o2-admin.bta.kilroy" PEER bta.kilroy

sh utils/enrollNode.sh peer0 Peer-O1-SuperAdmin-Pw o2-admin 7056 RCA tls-root-cert/tls-ca-cert.pem "localhost,*.o2-admin.bta.kilroy" PEER bta.kilroy
# Peer Starts

#Company ADMIN ENDS------
sleep 2

pid_rca=$(lsof -i tcp:7055 | grep fabric-ca | awk '{print $2}')
pid_ica=$(lsof -i tcp:7056 | grep fabric-ca | awk '{print $2}')

echo "RCA PID: " $pid_rca
echo "ICA PID: " $pid_ica

kill -9 $pid_rca

kill -9 $pid_ica

sleep 2

#StakeHolder STARTS------

sh utils/registerAdminUser.sh rca-o3-sh-bta-kilroy Rca-O3-Sh-Bta-Kilroy 7054 tls-root-cert/tls-ca-cert.pem tls-ca/tls-admin/msp RCA

sh utils/enrollAdminUser.sh rca-o3-sh-bta-kilroy Rca-O3-Sh-Bta-Kilroy RCA 7054 TLS tls-root-cert/tls-ca-cert.pem 'host1,localhost'

sh utils/registerAdminUser.sh ica-o3-sh-bta-kilroy Ica-O3-Sh-Bta-Kilroy 7054 tls-root-cert/tls-ca-cert.pem tls-ca/tls-admin/msp RCA

sh utils/enrollAdminUser.sh ica-o3-sh-bta-kilroy Ica-O3-Sh-Bta-Kilroy RCA 7054 TLS tls-root-cert/tls-ca-cert.pem 'host1,localhost'

sh utils/deployServer.sh rca-o3-sh-bta-kilroy-server rca-o3-sh-bta-kilroy Rca-O3-Sh-Bta-Kilroy RCA 7055 fabric-ca-client 127.0.0.1:9444 & 

sleep 2

sh utils/enrollAdminUser.sh rca-o3-sh-bta-kilroy Rca-O3-Sh-Bta-Kilroy RCA 7055 RCA tls-root-cert/tls-ca-cert.pem 'host1,localhost'

sh utils/registerAdminUser.sh ica-o3-sh-bta-kilroy Ica-O3-Sh-Bta-Kilroy 7055 tls-root-cert/tls-ca-cert.pem org-ca/rca-o3-sh-bta-kilroy/msp ICA

sh utils/deployServer.sh ica-o3-sh-bta-kilroy-server ica-o3-sh-bta-kilroy Ica-O3-Sh-Bta-Kilroy ICA 7056 fabric-ca-client 127.0.0.1:9445 fabric-ca-server-tls rca-o3-sh-bta-kilroy Rca-O3-Sh-Bta-Kilroy 7055 & 

sleep 2

sh utils/enrollAdminUser.sh ica-o3-sh-bta-kilroy Ica-O3-Sh-Bta-Kilroy RCA 7056 RCA tls-root-cert/tls-ca-cert.pem 'host1,localhost'

# PEER ADMIN STARTS
sh utils/registerNodeAdminTLS.sh peer Peer-Admin-Pw 7054 tls-root-cert/tls-ca-cert.pem tls-ca/tls-admin/msp/ PEER_ADMIN o3-sh bta.kilroy

sh utils/registerNode.sh peer Peer-Admin-Pw 7056 tls-root-cert/tls-ca-cert.pem org-ca/ica-o3-sh-bta-kilroy/msp/ PEER_ADMIN o3-sh bta.kilroy

sh utils/enrollNode.sh peer Peer-Admin-Pw o3-sh 7054 TLS tls-root-cert/tls-ca-cert.pem "localhost,*.o3-sh.bta.kilroy" PEER_ADMIN bta.kilroy

sh utils/enrollNode.sh peer Peer-Admin-Pw o3-sh 7056 RCA tls-root-cert/tls-ca-cert.pem 'localhost,*.o3-sh.bta.kilroy' PEER_ADMIN bta.kilroy

# PEER ADMIN ENDS

# PEER STARTS

sh utils/registerNode.sh peer0 Peer-O1-SuperAdmin-Pw 7054 tls-root-cert/tls-ca-cert.pem tls-ca/tls-admin/msp/ PEER o3-sh bta.kilroy

sh utils/registerNode.sh peer0 Peer-O1-SuperAdmin-Pw 7056 tls-root-cert/tls-ca-cert.pem org-ca/ica-o3-sh-bta-kilroy/msp/ PEER o3-sh bta.kilroy

sh utils/enrollNode.sh peer0 Peer-O1-SuperAdmin-Pw o3-sh 7054 TLS tls-root-cert/tls-ca-cert.pem "localhost,*.o3-sh.bta.kilroy" PEER bta.kilroy

sh utils/enrollNode.sh peer0 Peer-O1-SuperAdmin-Pw o3-sh 7056 RCA tls-root-cert/tls-ca-cert.pem "localhost,*.o3-sh.bta.kilroy" PEER bta.kilroy

# PEER ENDS

#StakeHolder ENDS------

sleep 2

pid_rca=$(lsof -i tcp:7055 | grep fabric-ca | awk '{print $2}')
pid_ica=$(lsof -i tcp:7056 | grep fabric-ca | awk '{print $2}')

echo "RCA PID: " $pid_rca
echo "ICA PID: " $pid_ica

kill -9 $pid_rca

kill -9 $pid_ica

sleep 2


#MLOps STARTS------

sh utils/registerAdminUser.sh rca-o4-mlops-bta-kilroy Rca-O4-MLOps-Bta-Kilroy 7054 tls-root-cert/tls-ca-cert.pem tls-ca/tls-admin/msp RCA

sh utils/enrollAdminUser.sh rca-o4-mlops-bta-kilroy Rca-O4-MLOps-Bta-Kilroy RCA 7054 TLS tls-root-cert/tls-ca-cert.pem 'host1,localhost'

sh utils/registerAdminUser.sh ica-o4-mlops-bta-kilroy Ica-O4-MLOps-Bta-Kilroy 7054 tls-root-cert/tls-ca-cert.pem tls-ca/tls-admin/msp RCA

sh utils/enrollAdminUser.sh ica-o4-mlops-bta-kilroy Ica-O4-MLOps-Bta-Kilroy RCA 7054 TLS tls-root-cert/tls-ca-cert.pem 'host1,localhost'

sh utils/deployServer.sh rca-o4-mlops-bta-kilroy-server rca-o4-mlops-bta-kilroy Rca-O4-MLOps-Bta-Kilroy RCA 7055 fabric-ca-client 127.0.0.1:9444 & 

sleep 2

sh utils/enrollAdminUser.sh rca-o4-mlops-bta-kilroy Rca-O4-MLOps-Bta-Kilroy RCA 7055 RCA tls-root-cert/tls-ca-cert.pem 'host1,localhost'

sh utils/registerAdminUser.sh ica-o4-mlops-bta-kilroy Ica-O4-MLOps-Bta-Kilroy 7055 tls-root-cert/tls-ca-cert.pem org-ca/rca-o4-mlops-bta-kilroy/msp ICA

sh utils/deployServer.sh ica-o4-mlops-bta-kilroy-server ica-o4-mlops-bta-kilroy Ica-O4-MLOps-Bta-Kilroy ICA 7056 fabric-ca-client 127.0.0.1:9445 fabric-ca-server-tls rca-o4-mlops-bta-kilroy Rca-O4-MLOps-Bta-Kilroy 7055 & 

sleep 2


sh utils/enrollAdminUser.sh ica-o4-mlops-bta-kilroy Ica-O4-MLOps-Bta-Kilroy RCA 7056 RCA tls-root-cert/tls-ca-cert.pem 'host1,localhost'


# PEER ADMIN STARTS----
sh utils/registerNodeAdminTLS.sh peer Peer-Admin-Pw 7054 tls-root-cert/tls-ca-cert.pem tls-ca/tls-admin/msp/ PEER_ADMIN o4-mlops bta.kilroy

sh utils/registerNode.sh peer Peer-Admin-Pw 7056 tls-root-cert/tls-ca-cert.pem org-ca/ica-o4-mlops-bta-kilroy/msp/ PEER_ADMIN o4-mlops bta.kilroy

sh utils/enrollNode.sh peer Peer-Admin-Pw o4-mlops 7054 TLS tls-root-cert/tls-ca-cert.pem "localhost,*.o4-mlops.bta.kilroy" PEER_ADMIN bta.kilroy

sh utils/enrollNode.sh peer Peer-Admin-Pw o4-mlops 7056 RCA tls-root-cert/tls-ca-cert.pem 'localhost,*.o4-mlops.bta.kilroy' PEER_ADMIN bta.kilroy

# PEER ADMIN ENDS----

# PEER STARTS----

sh utils/registerNode.sh peer0 Peer-O1-SuperAdmin-Pw 7054 tls-root-cert/tls-ca-cert.pem tls-ca/tls-admin/msp/ PEER o4-mlops bta.kilroy

sh utils/registerNode.sh peer0 Peer-O1-SuperAdmin-Pw 7056 tls-root-cert/tls-ca-cert.pem org-ca/ica-o4-mlops-bta-kilroy/msp/ PEER o4-mlops bta.kilroy

sh utils/enrollNode.sh peer0 Peer-O1-SuperAdmin-Pw o4-mlops 7054 TLS tls-root-cert/tls-ca-cert.pem "localhost,*.o4-mlops.bta.kilroy" PEER bta.kilroy

sh utils/enrollNode.sh peer0 Peer-O1-SuperAdmin-Pw o4-mlops 7056 RCA tls-root-cert/tls-ca-cert.pem "localhost,*.o4-mlops.bta.kilroy" PEER bta.kilroy

# PEER ENDS----
# MLOps ENDS------

sleep 2

pid_rca=$(lsof -i tcp:7055 | grep fabric-ca | awk '{print $2}')
pid_ica=$(lsof -i tcp:7056 | grep fabric-ca | awk '{print $2}')

echo "RCA PID: " $pid_rca
echo "ICA PID: " $pid_ica

kill -9 $pid_rca

kill -9 $pid_ica

sleep 2

# AI ENGINEER STARTS------

sh utils/registerAdminUser.sh rca-o5-ai-engineer-bta-kilroy Rca-O5-AI-Engineer-Bta-Kilroy 7054 tls-root-cert/tls-ca-cert.pem tls-ca/tls-admin/msp RCA

sh utils/enrollAdminUser.sh rca-o5-ai-engineer-bta-kilroy Rca-O5-AI-Engineer-Bta-Kilroy RCA 7054 TLS tls-root-cert/tls-ca-cert.pem 'host1,localhost'

sh utils/registerAdminUser.sh ica-o5-ai-engineer-bta-kilroy Ica-O5-AI-Engineer-Bta-Kilroy 7054 tls-root-cert/tls-ca-cert.pem tls-ca/tls-admin/msp RCA

sh utils/enrollAdminUser.sh ica-o5-ai-engineer-bta-kilroy Ica-O5-AI-Engineer-Bta-Kilroy RCA 7054 TLS tls-root-cert/tls-ca-cert.pem 'host1,localhost'

sh utils/deployServer.sh rca-o5-ai-engineer-bta-kilroy-server rca-o5-ai-engineer-bta-kilroy Rca-O5-AI-Engineer-Bta-Kilroy RCA 7055 fabric-ca-client 127.0.0.1:9444 & 

sleep 2

sh utils/enrollAdminUser.sh rca-o5-ai-engineer-bta-kilroy Rca-O5-AI-Engineer-Bta-Kilroy RCA 7055 RCA tls-root-cert/tls-ca-cert.pem 'host1,localhost'

sh utils/registerAdminUser.sh ica-o5-ai-engineer-bta-kilroy Ica-O5-AI-Engineer-Bta-Kilroy 7055 tls-root-cert/tls-ca-cert.pem org-ca/rca-o5-ai-engineer-bta-kilroy/msp ICA

sh utils/deployServer.sh ica-o5-ai-engineer-bta-kilroy-server ica-o5-ai-engineer-bta-kilroy Ica-O5-AI-Engineer-Bta-Kilroy ICA 7056 fabric-ca-client 127.0.0.1:9445 fabric-ca-server-tls rca-o5-ai-engineer-bta-kilroy Rca-O5-AI-Engineer-Bta-Kilroy 7055 & 

sleep 2

sh utils/enrollAdminUser.sh ica-o5-ai-engineer-bta-kilroy Ica-O5-AI-Engineer-Bta-Kilroy RCA 7056 RCA tls-root-cert/tls-ca-cert.pem 'host1,localhost'


# PEER ADMIN STARTS----

sh utils/registerNodeAdminTLS.sh peer Peer-Admin-Pw 7054 tls-root-cert/tls-ca-cert.pem tls-ca/tls-admin/msp/ PEER_ADMIN o5-ai-engineer bta.kilroy

sh utils/registerNode.sh peer Peer-Admin-Pw 7056 tls-root-cert/tls-ca-cert.pem org-ca/ica-o5-ai-engineer-bta-kilroy/msp/ PEER_ADMIN o5-ai-engineer bta.kilroy

sh utils/enrollNode.sh peer Peer-Admin-Pw o5-ai-engineer 7054 TLS tls-root-cert/tls-ca-cert.pem "localhost,*.o5-ai-engineer.bta.kilroy" PEER_ADMIN bta.kilroy

sh utils/enrollNode.sh peer Peer-Admin-Pw o5-ai-engineer 7056 RCA tls-root-cert/tls-ca-cert.pem 'localhost,*.o5-ai-engineer.bta.kilroy' PEER_ADMIN bta.kilroy

# PEER ADMIN STARTS----

# PEER STARTS----

sh utils/registerNode.sh peer0 Peer-O1-SuperAdmin-Pw 7054 tls-root-cert/tls-ca-cert.pem tls-ca/tls-admin/msp/ PEER o5-ai-engineer bta.kilroy

sh utils/registerNode.sh peer0 Peer-O1-SuperAdmin-Pw 7056 tls-root-cert/tls-ca-cert.pem org-ca/ica-o5-ai-engineer-bta-kilroy/msp/ PEER o5-ai-engineer bta.kilroy

sh utils/enrollNode.sh peer0 Peer-O1-SuperAdmin-Pw o5-ai-engineer 7054 TLS tls-root-cert/tls-ca-cert.pem "localhost,*.o5-ai-engineer.bta.kilroy" PEER bta.kilroy

sh utils/enrollNode.sh peer0 Peer-O1-SuperAdmin-Pw o5-ai-engineer 7056 RCA tls-root-cert/tls-ca-cert.pem "localhost,*.o5-ai-engineer.bta.kilroy" PEER bta.kilroy

# PEER ENDS----

# AI ENGINEER ENDS------

sleep 2

pid_rca=$(lsof -i tcp:7055 | grep fabric-ca | awk '{print $2}')
pid_ica=$(lsof -i tcp:7056 | grep fabric-ca | awk '{print $2}')

echo "RCA PID: " $pid_rca
echo "ICA PID: " $pid_ica

kill -9 $pid_rca

kill -9 $pid_ica

sleep 2

# ORDERER STARTS------

sh utils/registerAdminUser.sh rca-orderer Rca-Orderer-Pw 7054 tls-root-cert/tls-ca-cert.pem tls-ca/tls-admin/msp RCA

sh utils/enrollAdminUser.sh rca-orderer Rca-Orderer-Pw RCA 7054 TLS tls-root-cert/tls-ca-cert.pem 'host1,localhost'

sh utils/deployServer.sh rca-orderer-server rca-orderer Rca-Orderer-Pw RCA 7057 fabric-ca-client 127.0.0.1:9446 & 

sleep 2

sh utils/enrollAdminUser.sh rca-orderer Rca-Orderer-Pw RCA 7057 RCA tls-root-cert/tls-ca-cert.pem 'host1,localhost'

# ORDERER ADMIN STARTS------

sh utils/registerNodeAdminTLS.sh orderer Orderer-Admin-Pw 7054 tls-root-cert/tls-ca-cert.pem tls-ca/tls-admin/msp/ ORDERER_ADMIN org bta.kilroy

sh utils/registerNode.sh orderer Orderer-Admin-Pw 7057 tls-root-cert/tls-ca-cert.pem org-ca/rca-orderer/msp/ ORDERER_ADMIN org bta.kilroy

sh utils/enrollNode.sh orderer Orderer-Admin-Pw org 7054 TLS tls-root-cert/tls-ca-cert.pem "localhost,*.org.bta.kilroy" ORDERER_ADMIN bta.kilroy

sh utils/enrollNode.sh orderer Orderer-Admin-Pw org 7057 RCA tls-root-cert/tls-ca-cert.pem 'localhost,*.org.bta.kilroy' ORDERER_ADMIN bta.kilroy

# ORDERER ADMIN ENDS------

# ORDERER0 STARTS------

sh utils/registerNode.sh orderer0 Orderer0-Pw 7054 tls-root-cert/tls-ca-cert.pem tls-ca/tls-admin/msp/ ORDERER org bta.kilroy

sh utils/registerNode.sh orderer0 Orderer0-Pw 7057 tls-root-cert/tls-ca-cert.pem org-ca/rca-orderer/msp/ ORDERER org bta.kilroy

sh utils/enrollNode.sh orderer0 Orderer0-Pw org 7054 TLS tls-root-cert/tls-ca-cert.pem "localhost,*.org.bta.kilroy" ORDERER bta.kilroy

sh utils/enrollNode.sh orderer0 Orderer0-Pw org 7057 RCA tls-root-cert/tls-ca-cert.pem "localhost,*.org.bta.kilroy" ORDERER bta.kilroy

# ORDERER0 ENDS------

# ORDERER1 STARTS------
sh utils/registerNode.sh orderer1 Orderer1-Pw 7054 tls-root-cert/tls-ca-cert.pem tls-ca/tls-admin/msp/ ORDERER org bta.kilroy

sh utils/registerNode.sh orderer1 Orderer1-Pw 7057 tls-root-cert/tls-ca-cert.pem org-ca/rca-orderer/msp/ ORDERER org bta.kilroy

sh utils/enrollNode.sh orderer1 Orderer1-Pw org 7054 TLS tls-root-cert/tls-ca-cert.pem "localhost,*.org.bta.kilroy" ORDERER bta.kilroy

sh utils/enrollNode.sh orderer1 Orderer1-Pw org 7057 RCA tls-root-cert/tls-ca-cert.pem "localhost,*.org.bta.kilroy" ORDERER bta.kilroy
# ORDERER1 ENDS------

# ORDERER2 STARTS------

sh utils/registerNode.sh orderer2 Orderer2-Pw 7054 tls-root-cert/tls-ca-cert.pem tls-ca/tls-admin/msp/ ORDERER org bta.kilroy

sh utils/registerNode.sh orderer2 Orderer2-Pw 7057 tls-root-cert/tls-ca-cert.pem org-ca/rca-orderer/msp/ ORDERER org bta.kilroy

sh utils/enrollNode.sh orderer2 Orderer2-Pw org 7054 TLS tls-root-cert/tls-ca-cert.pem "localhost,*.org.bta.kilroy" ORDERER bta.kilroy

sh utils/enrollNode.sh orderer2 Orderer2-Pw org 7057 RCA tls-root-cert/tls-ca-cert.pem "localhost,*.org.bta.kilroy" ORDERER bta.kilroy
# ORDERER2 ENDS------

# ORDERER ENDS------

sleep 2

pid_oca=$(lsof -i tcp:7057 | grep fabric-ca | awk '{print $2}')
pid_tlsca=$(lsof -i tcp:7054 | grep fabric-ca | awk '{print $2}')

echo "OCA PID: " $pid_oca
echo "TLSCA PID: " $pid_tlsca

kill -9 $pid_oca

kill -9 $pid_tlsca

sleep 2