*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library            RPA.Browser.Selenium    auto_close=${False}
Library    RPA.HTTP
Library    RPA.Tables 
Library    RPA.Desktop


*** Variables ***
${URL}=    https://robotsparebinindustries.com/
${DOWNLOADURL}=       https://robotsparebinindustries.com/orders.csv
${currdir}=    D:\\_PROJECTS\\Robocorp projects\\robot-framework-demo\\
${data}
${delay}=    10 sec



*** Tasks ***
Open the intranet site and log in
    Open the intranet website
    Log in
    Close the annoying modal
    Get orders
    Fill the forms and submit order

    



*** Keywords ***
Open the intranet website
    Open Available Browser    ${URL}
    Maximize Browser Window

Log in
    Input Text    username    maria
    Input Password    password    thoushallnotpass
    Submit Form

Get orders
    Download     
    ...    ${DOWNLOADURL}    
    ...    overwrite=${True}

Read CSV File
    ${data}=    Read table from CSV   path=${currdir}orders.csv    
    FOR    ${row}    IN    @{data}
        Log    ${row}
    END
    RETURN    ${data}
    
Close the annoying modal
    Go To    https://robotsparebinindustries.com/#/robot-order
    Click Button    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]

Fill the form
    [Arguments]    ${row}
    Select From List By Value    head    ${row}[Head]
    Click Element    id:id-body-${row}[Body]
    Input Text    css:div>input    ${row}[Legs]
    Input Text    address    ${row}[Address]
    Scroll Element Into View    id:order
    Sleep    ${delay} 
    Click Button    id:order
    Sleep    ${delay} 
    Click Button    order-another
    Click Button    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]


Fill the forms and submit order
    ${data}=    Read CSV File
    FOR    ${row}    IN    @{data}
        Fill the form    ${row}
    END