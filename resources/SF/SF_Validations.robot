*** Settings ***
Library    RequestsLibrary
Library    SeleniumLibrary
Resource    ${EXECDIR}/config/SF_Variables.robot
Resource    ${EXECDIR}/resources/SF/SF_xpath_variables.robot

*** Variables ***
${expected_name}    
${first_name}
${last_name}

*** Keywords ***
Veify Contact ID is Created in Salesforce
    [Arguments]    ${contact_id}    ${marital_status} 
    Login to Salesforce    ${contact_id}
    ${expected_name}     Set Variable    ${first_name} ${last_name}
    Wait Until Element Is Visible    ${contact_name}    timeout=${INTERMEDIATE_WAIT_TIME} 
    ${actual_name}=    Get Text    ${contact_name}
    Wait Until Element Is Visible    ${details_tab}    timeout=${INTERMEDIATE_WAIT_TIME}
    # Wait Until Element Is Visible    ${marital_status_visible}    timeout=${INTERMEDIATE_WAIT_TIME}
    # Scroll Element Into View         ${marital_status_visible}
    # Sleep                            2s    # Allow time for the element to load after scrolling
    # Wait Until Element Is Visible    ${marital_status_visible}    timeout=${INTERMEDIATE_WAIT_TIME}
    # ${actual_status}=                Get Text    ${marital_status_visible}

    # Should Be Equal    ${actual_status}    ${marital_status}
    Should Be Equal    ${actual_name}    ${expected_name}
    Capture Page Screenshot
    

Login to Salesforce
    [Documentation]    Login to Salesforce
    [Arguments]    ${id_value}
    ${URL}=    Set Variable    ${SF_BASE_URL}/${id_value}
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Wait And Input    ${USERNAME_FIELD}    ${USERNAME}    ${MINIMAL_WAIT_TIME}
    Wait And Input    ${PASSWORD_FIELD}    ${PASSWORD}    ${MINIMAL_WAIT_TIME}
    Click Button    ${signInButton}

Wait And Input
    [Arguments]    ${locator}    ${text}    ${timeout}
    Wait Until Element Is Visible    ${locator}    ${timeout}
    Input Text    ${locator}    ${text}