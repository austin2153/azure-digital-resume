// when content is loaded run counter function
window.addEventListener("DOMContentLoaded", (event) => {
    getVisitCount();
});

const functionApiUrl = "https://aclab-functionapp-01.azurewebsites.net/api/GetResumeCounter?code=2U9SQtY75gyOvGkPGBfK-kCaVIXS6Fkqnq6zLaxNFw2aAzFuCLgD5Q==";
const localFunctionApi = "http://localhost:7071/api/GetResumeCounter";

const getVisitCount = () => {
    let count = 30;
    fetch(functionApiUrl).then(response => {
        return response.json()
    }).then(response => {
        count = response.count;
        console.log("count: " + count);
        document.getElementById("counter").innerText = count;
    }).catch(function(error){
        console.log(error);
    })
    return count;
}
