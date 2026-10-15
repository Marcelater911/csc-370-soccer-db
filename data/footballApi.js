// Fetch the football API
import path from 'path';
import fs from 'fs';
import dotenv from 'dotenv';

console.log("Current meta property information:", import.meta);
dotenv.config({ path: path.join(import.meta.dirname, '.env') });

const url = "https://v3.football.api-sports.io/timezone";
const apiKey = process.env.FOOTBALL_API_KEY;

if(!apiKey){
    throw new Error("API Key does not exist")
}

const saveJsonToCsv = (jsonData, filePath) => {
    const list = Array.isArray(jsonData) ? jsonData : [jsonData];
    const rows = list.map((item) => (item !== null && typeof item === "object" ? item : { value: item }));
    if (rows.length === 0) {
        fs.writeFileSync(filePath, "");
        return;
    }

    const escapeValue = (value) => {
        const stringValue = value === null || value === undefined ? "" : String(value);
        if (/[",\n]/.test(stringValue)) {
            return `"${stringValue.replace(/"/g, '""')}"`;
        }
        return stringValue;
    };

    const headers = Object.keys(rows[0]);
    const csvLines = [
        headers.join(","),
        ...rows.map((row) => headers.map((header) => escapeValue(row[header])).join(","))
    ];

    fs.writeFileSync(filePath, csvLines.join("\n"));
};

const footballApi = async (url, apiKey) => {
    try{
        var res = await fetch(url, {
            method: "GET",
            headers: {
                "x-apisports-key": `${apiKey}`
            }
        })
        if(!res.ok){
            throw new Error(`HTTP rror! status ${res.status}`);
        }
        const data = await res.json();
        return data;
    } catch(error){
        return console.error("Error fetching data from the API:", error);
    }
}

const data = await footballApi(url, apiKey);
console.log(data);

if (data) {
    const outputPath = path.join(import.meta.dirname, "timezones.csv");
    saveJsonToCsv(data.response ?? data, outputPath);
    console.log(`Saved data to ${outputPath}`);
}