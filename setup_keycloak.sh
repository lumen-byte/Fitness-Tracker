#!/bin/bash
echo "Waiting for Keycloak to start..."
while ! curl -s -f http://localhost:8181/health/ready; do
    sleep 5
    echo -n "."
done
echo "Keycloak is ready!"

# Get Admin Token
TOKEN=$(curl -s -X POST "http://localhost:8181/realms/master/protocol/openid-connect/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=admin" \
    -d "password=admin" \
    -d "grant_type=password" \
    -d "client_id=admin-cli" | jq -r '.access_token')

if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
    echo "Failed to obtain admin token"
    exit 1
fi

echo "Creating Realm: fitness-oauth2"
curl -s -X POST "http://localhost:8181/admin/realms" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "realm": "fitness-oauth2",
        "enabled": true
    }'

echo "Creating Client: oauth2-pkce-client"
curl -s -X POST "http://localhost:8181/admin/realms/fitness-oauth2/clients" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "clientId": "oauth2-pkce-client",
        "enabled": true,
        "publicClient": true,
        "standardFlowEnabled": true,
        "implicitFlowEnabled": false,
        "directAccessGrantsEnabled": true,
        "redirectUris": ["http://localhost:5173/*"],
        "webOrigins": ["http://localhost:5173"]
    }'

echo "Creating User: testuser"
curl -s -X POST "http://localhost:8181/admin/realms/fitness-oauth2/users" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "username": "testuser",
        "enabled": true,
        "emailVerified": true,
        "firstName": "Test",
        "lastName": "User",
        "credentials": [{
            "type": "password",
            "value": "password123",
            "temporary": false
        }]
    }'

echo "Keycloak Setup Complete!"
