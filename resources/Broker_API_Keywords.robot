*** Settings ***
Resource    ${EXECDIR}/resources/master.robot
Resource    ${EXECDIR}/resources/API/POST_API_Requests.robot

*** Variables ***
${tourWaveAllotmentId}    ${None}
${date}    ${None}

*** Keywords ***
Test Broker Cancellation
    [Documentation]    Test Broker Cancel
    [Arguments]    ${marital_status}    ${status_code}    ${message}
    Get Auth Token
    ${contact_id}=    Create Contact ID    ${marital_status}    ${status_code}    ${message}
    Set Suite Variable    ${contact_id}
    #Run Keyword If    '${contact_id}' != '${null}'    Veify Contact ID is Created in Salesforce    ${contact_id}    ${marital_status} 
    #only if contact id is not null, send tour reservation request
    Create Tour Booking
    Create Reservation
    Cancel Reservation Booking
    

Get Auth Token
    [Documentation]    Get Access Token    
    ${ACCESS_TOKEN}=    GET Access Token
    Set Suite Variable    ${ACCESS_TOKEN}

Create Contact ID
    [Documentation]    Create Contact ID
    [Arguments]    ${marital_status}    ${status_code}    ${message}    
    ${contact_id}=    Send Credit Eligibility Request    ${marital_status}      ${status_code}    ${message}
    RETURN    ${contact_id}

Create Tour Booking
    [Documentation]    Create Tour Reservation Request
    Send Tour Booking Request
    
Create Reservation
    [Documentation]    Create Reservation Request
    Send Reservation Request
