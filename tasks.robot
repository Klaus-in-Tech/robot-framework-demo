*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library            RPA.Browser.Selenium
Library    RPA.HTTP
Library    RPA.Tables 


*** Variables ***
${URL}=     https://robotsparebinindustries.com/
${DOWNLOADURL}=       https://robotsparebinindustries.com/orders.csv
${currdir}=    D:\\_PROJECTS\\Robocorp projects\\robot-framework-demo\\





*** Tasks ***
Open the intranet site and log in
    #Open the intranet website
    #Log in
    #Get orders
    Read CSV File
    



*** Keywords ***
Open the intranet website
    Open Available Browser    ${URL}

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