*** Settings ***
Documentation       Robot completes Finnish national upper secondary schools exam using ChatGPT.
Library             RPA.Browser.Playwright
Library    RPA.Robocorp.Vault
Library    RPA.OpenAI
Library    String

*** Variables ***
${url}   https://yle.fi/aihe/abitreenit/harjoittele
${cookies}   //button[contains(text(),'Vain välttämättömät')]
${question_number}   1
${exam}   uskonto-ortodoksinen
&{results}   A=1   B=2   C=3   D=4 
${exam_selection}    //span[contains(text(),'syksy 2022')]

*** Tasks ***
Finnish national upper secondary schools exam
    Authorize to ChatGPT
    Open Browser and accept cookies
    Select and start the Exam
    WHILE    ${question_number} <= ${20}
        Answer the Question   ${question_number}
        ${question_number}  Evaluate    ${question_number}+1
    END
    Sleep    20

*** Keywords ***
Authorize to ChatGPT
    ${secrets}   Get Secret   secret_name=OpenAI
    Authorize To OpenAI   api_key=${secrets}[key]

Open Browser and accept cookies
    Open Browser   ${url}  
    Click   ${cookies}

Select and start the Exam
    Select Options By    //select[@id="yo-select--aine"]    value     ${exam}
    Click   ${exam_selection}

Answer the Question
    [Arguments]  ${question_number}
    Scroll To Element    (//button[starts-with(@aria-label, 'Tarkista')])[${question_number}]
    ${question}=   Get Text    (//strong[contains(text(),"1")])[${question_number}]/ancestor::span  
    ${question}=   Fetch From Left    ${question}    ${SPACE}1
    Log To Console    ${question} 
    ${answer_option_A}   Get text   ((//*[@class="yo-multiple-choice-question__options"])[${question_number}]//span)[1]
    ${answer_option_B}   Get text   ((//*[@class="yo-multiple-choice-question__options"])[${question_number}]//span)[3] 
    ${answer_option_C}   Get text   ((//*[@class="yo-multiple-choice-question__options"])[${question_number}]//span)[5]
    ${answer_option_D}   Get text   ((//*[@class="yo-multiple-choice-question__options"])[${question_number}]//span)[7]

    ${resp}   @{conversation}   Chat Completion Create  
    ...    user_content=${question}: A=${answer_option_A}, B=${answer_option_B}, C=${answer_option_C}, D=${answer_option_D}. Vastaa vain oikean vastauksen kirjaimella A, B, C, D tai E ilman mitään muuta tekstiä. Pelkkä yksi kirjain.
    ...    temperature=0.2
    ${resp}   Strip String    ${resp}
    Log To Console    ${resp}

    Click    (((//*[@class="yo-multiple-choice-question__options"])[${question_number}])[1]//*[@class="ChoiceContainerstyles__ChoiceButtonContainer-sc-11i5r05-0 kvKlsK"])[${results}[${resp}]]
    Click    (//button[starts-with(@aria-label, 'Tarkista')])[${question_number}]
    Sleep    1
