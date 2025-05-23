*** Settings ***
Documentation     Broker Self Service Cancellation Tests
Resource          ${EXECDIR}/resources/Broker_API_Keywords.robot
Suite Setup       BrokerSelfService Suite Setup
Test Teardown     Close All Browsers
Test Template     Broker_Self_Service_End_To_End_Tests
Test Tags         BrokerSelfService



*** Test Cases ***                              ${vendor}        ${property_type}
Verify MonsterRes Booking Cancellation Flow     MonsterRes            resort
Verify MonsterRes hotel Booking Cancellation    MonsterRes            hotel

*** Keywords ***
Broker_Self_Service_End_To_End_Tests
    [Documentation]    Executes end-to-end broker self service cancellation tests
    [Arguments]    ${vendor}    ${property_type}
    [Setup]    BrokerSelfService Test Setup    ${vendor}    ${property_type}
    Execute Booking And Cancel Flow    ${vendor}
