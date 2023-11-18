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
${URL}=     https://robotsparebinindustries.com/
${DOWNLOADURL}=       https://robotsparebinindustries.com/orders.csv
${currdir}=    D:\\_PROJECTS\\Robocorp projects\\robot-framework-demo\\



*** Tasks ***
Open the intranet site and log in
    #Wait Until Keyword Succeeds    3x    0.5 sec    Open the intranet website
    #Log in
    #Close the annoying modal
    #Get orders
    Read CSV File
    



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
        Log To Console    ${row}
    END
    
Close the annoying modal
    Go To    https://robotsparebinindustries.com/#/robot-order
    Click Button    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]

Fill the form
    Print To Pdf
    
    