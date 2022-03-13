# 
# Random password generated for application to use
# 

PASSWORD="REACT_APP_PASSWORD_KEY=\"";
PASSWORD+="$(echo $RANDOM | md5sum | head -c 20)";
echo $PASSWORD"\"" > .env;