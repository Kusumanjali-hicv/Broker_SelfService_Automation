*** Settings ***
Library    RequestsLibrary
Library    SeleniumLibrary
Library    DateTime
Resource    ${EXECDIR}/config/SF_Variables.robot
Resource    ${EXECDIR}/resources/SF/SF_xpath_variables.robot

*** Variables ***
${expected_name}    
${first_name}   
${last_name}    
${contact_id}    
${opportunityId}    
${reservationRequestId}
${tourRequestId}
${SF_checkIn_date}
${SF_checkOut_date}
${tourWaveAllotmentId}
${length_of_stay}
${number_of_guests}

*** Keywords ***
Veify Contact ID is Created in Salesforce
    Navigate to Salesforce Page    ${contact_id}
    ${expected_name}=    Set Variable    ${first_name} ${last_name}
    Wait Until Element Is Visible    ${contact_name}    timeout=${INTERMEDIATE_WAIT_TIME} 
    ${actual_name}=    Get Text    ${contact_name}
    Wait Until Element Is Visible    ${details_tab}    timeout=${INTERMEDIATE_WAIT_TIME}
    Sleep    time_=20s
    Capture Page Screenshot
    Should Be Equal    ${actual_name}    ${expected_name}

    
Verify Reservation Status in Salesforce
    [Documentation]    Verifies reservation status in Salesforce
    [Arguments]    ${expected_status}
    Navigate to Salesforce Page    ${opportunityId}
    Wait Until Element Is Visible    ${primary_contact_field}    timeout=${INTERMEDIATE_WAIT_TIME}
    ${actual_status}=    Get Text    ${reservation_status}
    Wait Until Element Is Visible    ${number_of_nights_xpath}    timeout=${INTERMEDIATE_WAIT_TIME}
    ${actual_number_of_nights}=    Get Text    ${number_of_nights_xpath}
    Wait Until Element Is Visible    ${number_of_guests_xpath}    timeout=${INTERMEDIATE_WAIT_TIME}
    ${actual_number_of_guests}=    Get Text    ${number_of_guests_xpath}
    Scroll Element Into View    ${number_of_guests_xpath}
    Capture Page Screenshot
    Should Be Equal    ${actual_status}    ${expected_status}
    ${length_of_stay_str}=    Convert To String    ${length_of_stay}
    ${number_of_guests_str}=    Convert To String    ${number_of_guests}
    Should Be Equal    ${actual_number_of_nights}    ${length_of_stay_str}
    Should Be Equal    ${actual_number_of_guests}    ${number_of_guests_str}
    
Verify using reservationRequestId
    [Documentation]    Verifies active reservation in Salesforce
    Navigate to Salesforce Page    ${reservationRequestId}
    Wait Until Element Is Visible    ${checkin_date_xpath}    timeout=${INTERMEDIATE_WAIT_TIME}
    Sleep    time_=20s
    ${actual_checkin}=    Get Text    ${checkin_date_xpath}
    ${actual_checkout}=   Get Text    ${checkout_date_xpath}
    #${actual_checkin}=    Convert Date    ${actual_checkin}    result_format=%m/%d/%Y
    #${actual_checkout}=   Convert Date    ${actual_checkout}    result_format=%m/%d/%Y
    ${actual_checkin}=    Convert Date    ${actual_checkin}    date_format=%m/%d/%Y    result_format=%m/%d/%Y
    ${actual_checkout}=    Convert Date    ${actual_checkout}    date_format=%m/%d/%Y    result_format=%m/%d/%Y
    Should Be Equal    ${actual_checkin}    ${SF_checkIn_date}
    Should Be Equal    ${actual_checkout}    ${SF_checkOut_date}


Verify using tourRequestId
    [Documentation]    Verifies active reservation in Salesforce
    Navigate to Salesforce Page    ${tourRequestId}
    Wait Until Element Is Visible    ${tour_wave_allotment_id_xpath}    timeout=${INTERMEDIATE_WAIT_TIME}
    ${allotment_id}=    Get Text    ${tour_wave_allotment_id_xpath}    
    ${tourWaveAllotmentId_str}=    Convert To String    ${tourWaveAllotmentId}
    Should Be Equal    ${allotment_id}    ${tourWaveAllotmentId_str}

Verify Reservation in Salesforce
    [Documentation]    Verifies active reservation in Salesforce
    Run Keyword And Continue On Failure     Verify using reservationRequestId
    Run Keyword And Continue On Failure     Verify using tourRequestId
    Run Keyword And Continue On Failure     Verify Reservation Status in Salesforce    ${RESERVATION_SUCCESS_STATUS}

Verify Cancellation in Salesforce
    [Documentation]    Verifies cancelled reservation in Salesforce
    Verify Reservation Status in Salesforce    ${CANCEL_RESERVATION_STATUS}

Login to Salesforce
    [Documentation]    Initial login to Salesforce
    Open Browser    ${SF_BASE_URL}    ${BROWSER}
    Maximize Browser Window
    Wait And Input    ${USERNAME_FIELD}    ${USERNAME}    ${MINIMAL_WAIT_TIME}
    Wait And Input    ${PASSWORD_FIELD}    ${PASSWORD}    ${MINIMAL_WAIT_TIME}
    Click Button    ${signInButton}

Navigate to Salesforce Page
    [Documentation]    Navigate to specific Salesforce page
    [Arguments]    ${id_value}
    ${status}=    Run Keyword And Return Status    Get Window Handles
    Run Keyword If    not ${status}    Login to Salesforce    
    Go To    ${SF_BASE_URL}${id_value}
    Wait Until Location Contains    ${id_value}    timeout=${INTERMEDIATE_WAIT_TIME}
    Location Should Contain    ${id_value}

Wait And Input
    [Arguments]    ${locator}    ${value}    ${timeout}
    Wait Until Element Is Visible    ${locator}    timeout=${timeout}
    Input Text    ${locator}    ${value}