*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library    RPA.Browser.Selenium    auto_close=${False}
Library    RPA.HTTP
Library    RPA.Excel.Files    
Library    RPA.Tables
Library    RPA.RobotLogListener
Library    RPA.PDF
Library    RPA.FileSystem
Library    RPA.Archive

*** Tasks ***
Orders robots from RobotSpareBin Industries Inc.
    Open website
    Download orders file

*** Keywords ***

Open website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Close Box

Close Box
    Wait Until Page Contains Element  //button[@class="btn btn-dark"]
    Click Button  //button[@class="btn btn-dark"]

Fill for one order
    [Arguments]    ${data}
    Select From List By Value    //select[@name="head"]    ${data}[Head]
    Click Element    //input[@value=${data}[Body]]
    Input Text  //input[@placeholder="Enter the part number for the legs"]    ${data}[Legs]
    Input Text   //input[@placeholder="Shipping address"]     ${data}[Address]
  
Download orders file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
     ${datas}=  Read Table From Csv  orders.csv  header=True
    FOR    ${data}    IN    @{datas}
        Fill for one order    ${data} 
        Click Button    Preview
        Sleep    1s
        Click Button    //button[@id="order"]
        FOR  ${i}  IN RANGE  ${100}
        ${alert}=  Is Element Visible  //div[@class="alert alert-danger"]  
        Run Keyword If  '${alert}'=='True'  Click Button  //button[@id="order"] 
        Exit For Loop If  '${alert}'=='False'       
        END  
        Sleep    1s
        Make PDF    ${data}[Order number]
        Take Screenshot    ${data}[Order number]
        Click Button   //button[@id="order-another"]

        Close Box
    END
    Add files to ZIP
    

Make PDF
    [Arguments]    ${ORDER_NUMBER}
    Wait Until Element Is Visible    id:receipt
    ${res}=    Get Element Attribute    id:receipt     outerHTML 
    Create Directory  pdf
    Html To Pdf    ${res}    ${CURDIR}${/}pdf${/}receipt${ORDER_NUMBER}.pdf
    
Take Screenshot
    [Arguments]    ${ORDER_NUMBER}
    Create Directory    ss
    Screenshot    id:robot-preview    ${CURDIR}${/}ss${/}receipt${ORDER_NUMBER}.png
    Add Watermark Image To Pdf  ${CURDIR}${/}ss${/}receipt${Order number}.png  ${CURDIR}${/}pdf${/}receipt${Order number}.pdf  ${CURDIR}${/}pdf${/}receipt${Order number}.pdf

Add files to ZIP
    Archive Folder With Zip    ${CURDIR}${/}pdf${/}    ${OUTPUT_DIR}${/}pdf.ZIP
    Close Window