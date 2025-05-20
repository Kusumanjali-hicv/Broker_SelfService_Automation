*** Settings ***
Resource    ${EXECDIR}/resources/API/GetAuth.robot
Resource    ${EXECDIR}/resources/SF/SF_Validations.robot
Resource    ${EXECDIR}/config/JsonPaths.robot
Resource    ${EXECDIR}/config/TestData.robot
Resource    ${EXECDIR}/resources/util.robot
Resource    ${EXECDIR}/resources/API/GET_API_Requests.robot

*** Keywords ***
BrokerSelfService Test Setup
    [Documentation]    Retrieves test data from GET API methods
    [Arguments]    ${vendor}
    Run Keywords
        GET Access Token
        GET Campaign Id    ${vendor}
        GET Tour Allotments
        GET Packages
        GET Reservation Availabilities

BrokerSelfService Suite Setup
    [Documentation]    Initializes test data and dates
    Run Keywords
        Set Guests & Length of Stay
        Set Marital Status
        Set Checkin Checkout Date
        Generate Testdata
