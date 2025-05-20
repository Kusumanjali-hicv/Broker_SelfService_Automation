*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    JSONLibrary
Resource    ${EXECDIR}/config/ApplicationVariables.robot
Resource    ${EXECDIR}/config/api_endpoints.robot


*** Variables ***
${ACCESS_TOKEN}    



*** Keywords ***
GET Access Token
    ${headers}    Create Auth Headers
    ${query_params}    Create Auth Parameters
    ${response}    Make Auth Request    ${headers}    ${query_params}
    ${token}    Extract Token From Response    ${response}
    Set Suite Variable    ${ACCESS_TOKEN}    ${token}
    

Create Auth Headers
    ${headers}    Create Dictionary    ${CONTENT_TYPE_ID}=${CONTENT_TYPE_VALUE}
    RETURN    ${headers}

Create Auth Parameters
    ${query_params}    Create Dictionary
    ...    ${SCOPE_ID}=${SCOPE_VALUE}
    ...    ${GRANT_TYPE_ID}=${GRANT_TYPE_VALUE}
    ...    ${CLIENT_ID}=${CLIENT_VALUE}
    ...    ${CLIENT_SECRET_ID}=${CLIENT_SECRET_VALUE}
    RETURN    ${query_params}

Make Auth Request
    [Arguments]    ${headers}    ${query_params}
    Create Session    auth_session    ${BASE_AUTH_URL}    headers=${headers}    verify=true
    ${response}    POST On Session    auth_session    ${AUTH_URL}    params=${query_params}
    RETURN    ${response}

Extract Token From Response
    [Arguments]    ${response}
    ${token}    Get Value From Json    ${response.json()}    access_token
    RETURN    ${token}[0]