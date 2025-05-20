*** Settings ***
Resource    ${EXECDIR}/resources/master.robot
Resource    ${EXECDIR}/resources/API/POST_API_Requests.robot

*** Variables ***
${tourWaveAllotmentId}
${date}   
${contact_id}   

*** Keywords ***
Test Broker Cancellation
    [Documentation]    Executes complete broker cancellation flow
    [Arguments]    ${vendor}   
    GET Access Token   
    ${status}=    Run Keyword And Return Status    Complete Booking Process    ${vendor}
    Run Keyword If    ${status}    Cancel Reservation Booking
    ...    ELSE    Fail    Booking process failed

Complete Booking Process
    [Documentation]    Handles the complete booking flow
    [Arguments]    ${vendor}
    Check Credit Eligibility    ${vendor}
    Create Tour Booking
    Create Reservation

Check Credit Eligibility
    [Documentation]    Verifies credit eligibility and creates contact ID
    [Arguments]    ${vendor}   
    ${contact_id}=    Send Credit Eligibility Request    ${vendor}
    Set Suite Variable    ${contact_id}
    Should Not Be Equal    ${contact_id}    ${None}    Credit eligibility check failed

Create Tour Booking
    [Documentation]    Creates tour reservation
    Send Tour Booking Request
    
Create Reservation
    [Documentation]    Creates final reservation
    Send Reservation Request