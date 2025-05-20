*** Settings ***
Documentation     Broker Self Service Cancellation Tests
Resource          ${EXECDIR}/resources/Broker_API_Keywords.robot
Suite Setup       BrokerSelfService Suite Setup
Test Template     Broker_Self_Service_End_To_End_Tests
Test Tags         BrokerSelfService    Cancellation


*** Test Cases ***    ${vendor}        
Test MonsterRes       MonsterRes

*** Keywords ***
Broker_Self_Service_End_To_End_Tests
    [Documentation]    Executes end-to-end broker self service cancellation tests
    [Arguments]    ${vendor}    
    [Setup]    BrokerSelfService Test Setup    ${vendor}
    Test Broker Cancellation    ${vendor}   
