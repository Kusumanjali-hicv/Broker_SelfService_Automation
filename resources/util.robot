*** Settings ***
Library    String
Library     DateTime
Resource    ${EXECDIR}/config/TestData.robot

*** Variables ***
${length_of_stay}
${number_of_guests}

*** Keywords ***
Generate Random UUID
    ${uuid}=    Evaluate    str(uuid.uuid4())    modules=uuid
    Set Suite Variable    ${uuid}

Generate Email Id
    [Documentation]    Generate random email id
    ${first_name}=    Set Variable    QATest
    ${last_name}    Generate random string    4    abcdefghijklmnopqrstuvwxyz  
    ${com}=     Set variable    @mailinator.com
    ${email}=   Set variable    ${first_name}${last_name}${com}
    Set Suite Variable    ${email}
    Set Suite Variable    ${first_name}
    Set Suite Variable    ${last_name}
    RETURN    ${email}

Generate Phone Number
    [Documentation]    Generate random phone number
    ${ph_Number_1}    Generate random string    5    98765
    ${ph_Number_2}    Generate random string    5    0123456789
    ${phone}=    Set variable   ${ph_Number_1}${ph_Number_2}
    RETURN    ${phone}

Set Guests & Length of Stay
    [Documentation]    Set the number of guests and length of stay
    ${length_of_stay}    Evaluate    random.choice($LENGTH_OF_STAY_Array)    random
    ${length_of_stay}    Convert To Integer    ${length_of_stay}
    ${number_of_guests}    Evaluate    random.choice($NUMBER_OF_GUESTS_Array)    random
    Set Suite Variable    ${length_of_stay}    ${length_of_stay}
    Set Suite Variable    ${number_of_guests}    ${number_of_guests}

Set Marital Status
    ${marital_status}    Evaluate    random.choice($marital_status_list)    random
    Set Suite Variable    ${marital_status}

Generate Testdata
    Generate Email Id
    Generate Phone Number
    Generate Random UUID

Set Checkin Checkout Date
    [Documentation]    Set checkin checkout  date
    ${date}=    Get Current Date    result_format=%Y-%m-%d
    #add 7days to the current date
    ${checkIn_date}=    Add Time To Date    ${date}    ${length_of_stay} days    result_format=%Y-%m-%d    
    ${checkOut_date}=    Add Time To Date    ${checkIn_date}    ${length_of_stay} days    result_format=%Y-%m-%d
    
    
    Set Suite Variable    ${checkIn_date}
    Set Suite Variable    ${checkOut_date}