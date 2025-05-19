*** Settings ***
Resource    ${EXECDIR}/resources/API/GetAuth.robot
Resource    ${EXECDIR}/resources/SF/SF_Validations.robot
Resource    ${EXECDIR}/config/JsonPaths.robot
Resource    ${EXECDIR}/config/TestData.robot
Resource    ${EXECDIR}/resources/API/GET_API_Requests.robot

*** Keywords ***
BrokerSelfService Test Setup
    [Documentation]    Test Setup to get the required test data fromnGET API methods
    [Tags]    TestSetup
    Get Checkin Checkout Date
    GET Tour Allotments
    Get Packages
    Get Reservation Availabilities