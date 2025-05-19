*** Settings ***
Resource    ${EXECDIR}/resources/Broker_API_Keywords.robot
Test Template    Broker_Self_Service_Tests
Suite Setup      BrokerSelfService Test Setup
Test Teardown    Close All Browsers


*** Test Cases ***        ${marital_status}       ${status_code}        ${message}           
Test_01                   Married                       200               'Success' 
Test_02                   Single                        200               'Success'       
Test_03                   Co-hab                        200               'Success'
Test_04                   Married Man                   200               'Success'
Test_05                   Married Woman                 200               'Success'
Test_06                   Single Man                    200               'Success'
Test_07                   Single Woman                  200               'Success'    
Test_08                   Single Person                 200               'Success'
Test_09                   Unknown                       200               'Success'
Test_10                   ${EMPTY}                      400               '/maritalStatus ${SPACE}is not a valid enum value'
Test_11                   Household                     400               '/maritalStatus Household is not a valid enum value'




*** Variables ***
${response}

*** Keywords ***
Broker_Self_Service_Tests
    [Documentation]    Broker Self Service Cancellations tests
    [Arguments]    ${marital_status}    ${status_code}    ${message}
    [Tags]    BrokerSelfService
    Test Broker Cancellation    ${marital_status}      ${status_code}    ${message}
    
    

