*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    JSONLibrary
Resource    ${EXECDIR}/config/ApplicationVariables.robot
Resource    ${EXECDIR}/config/api_endpoints.robot


*** Keywords ***
GET Access Token
    ${headers}    Create Dictionary
    ...    ${CONTENT_TYPE_ID}=${CONTENT_TYPE_VALUE}
    ${query_params}    Create Dictionary
    ...    ${SCOPE_ID}=${SCOPE_VALUE}
    ...    ${GRANT_TYPE_ID}=${GRANT_TYPE_VALUE}
    ...    ${CLIENT_ID}=${CLIENT_VALUE}
    ...    ${CLIENT_SECRET_ID}=${CLIENT_SECRET_VALUE}
    Create Session    Session    ${BASE_AUTH_URL}    headers=${headers}    verify=true
    ${RESPONSE}    POST On Session    Session    ${AUTH_URL}    params=${query_params}
    ${access_token}=  Get Value From Json  ${RESPONSE.json()}  access_token
    RETURN    ${access_token}[0]