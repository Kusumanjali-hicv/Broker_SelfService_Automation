*** Settings ***
Resource    ${EXECDIR}/resources/master.robot
Resource    ${EXECDIR}/resources/API/POST_API_Requests.robot

*** Variables ***
${tourWaveAllotmentId}
${date}   
${contact_id}   

*** Keywords ***
Execute Booking And Cancel Flow
    [Documentation]    Executes complete broker cancellation flow
    [Arguments]    ${vendor}   
    GET Access Token   
    Complete Booking Process    ${vendor}
    Run Keyword And Continue On Failure    Verify in Salesforce
    Cancel Reservation
    

Complete Booking Process
    [Documentation]    Handles the complete booking flow    
    [Arguments]    ${vendor}
    ${status1}=    Run Keyword And Return Status    Check Credit Eligibility    ${vendor}
    Run Keyword If    not ${status1}    Fail    Credit eligibility check failed
    
    ${status2}=    Run Keyword And Return Status    Create Tour Booking
    Run Keyword If    not ${status2}    Fail    Tour booking creation failed
    
    ${status3}=    Run Keyword And Return Status    Create Reservation
    Run Keyword If    not ${status3}    Fail    Reservation creation failed
    
    RETURN    True


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

Cancel Reservation
    [Documentation]    Cancels the reservation booking
    Cancel Reservation Booking
    Verify Cancellation in Salesforce

Verify in Salesforce
    [Documentation]    Verifies the contact ID in Salesforce
    Veify Contact ID is Created in Salesforce
    Verify Reservation in Salesforce
    
