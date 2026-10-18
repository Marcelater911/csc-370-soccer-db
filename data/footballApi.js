// Fetch the football API
import path from 'path';
import fs from 'fs';
import dotenv from 'dotenv';

const currentDir = import.meta.dirname
// console.log("Current meta property information:", import.meta);
dotenv.config({ path: path.join(currentDir, '.env') });

/* API Key */
const apiKey = process.env.FOOTBALL_API_KEY;

/* timezone endpoint url + path */
const tzUrl = "https://v3.football.api-sports.io/timezone";
const tzOutPath = path.join(currentDir, "timezones.csv");

/* countries endpoint url */
const countriesUrl = "https://v3.football.api-sports.io/countries";
const countries_json_path = path.join(currentDir, "countries.json");
const countriesOutPath = path.join(currentDir, "countries.csv");
const euLeagueCountriesPath = path.join(currentDir, "countries.txt");

/* Leagues endpoint url + path */
const leaguesUrl = "https://v3.football.api-sports.io/leagues"
const leaguesCsvPath = path.join(currentDir, "leagues.csv")
const euLeaguesPath = path.join(currentDir, "eu_leagues.txt")

/* Teams for each league url + path */
// Ligue 1 season 2023-24
const teamsUrl = "https://v3.football.api-sports.io/teams?league=61&season=2023"
const teamsCsvPath = path.join(currentDir, "teams.csv")

const countryList = ["england", "france", "germany", "spain", "italy"]

if(!apiKey){
    throw new Error("API Key does not exist")
}

export const footballApi = async (url, apiKey) => {
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

const filterDataByName = (data, names, type) => {
    const nameSet = new Set(names.map((name) => name.toLowerCase()));
    if (!type) {
        throw new Error("Type parameter is required for filtering data.");   
    }
    // Filters all leagues that has a name of premier League, la liga, serie a, bundesliga, ligue 1 and is in the country list
    if (type === "country") {
        return data.filter((data) => nameSet.has(data.name.toLowerCase()) || nameSet.has(data.code.toLowerCase()));
    }
    else if (type === "league") {
        return data.filter((item) => nameSet.has(item.league.name.toLowerCase()) && countryList.includes(item.country.name.toLowerCase()));
    } else {
        return data.filter((data) => nameSet.has(data.name.toLowerCase()));
    }
}

const saveJsonToCsv = (jsonData, filePath, type) => {
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

    if (type === "country" || type === "timezone") {
        const headers = Object.keys(rows[0]);
        const csvLines = [
            headers.join(","),
            ...rows.map((row) => headers.map((header) => escapeValue(row[header])).join(","))
        ];

        fs.writeFileSync(filePath, csvLines.join("\n"));
    } else if (type === "league") {
        const headers = ["league_id", "league_name", "country_name", "country_code", "seasons"];
        const csvLines = [
            headers.join(","),
            ...rows.map((row) => {
                const league = row.league || {};
                const country = row.country || {};
                const seasons = (row.seasons || []).map(({ year, start, end, current }) => ({ year, start, end, current }));
                return [
                    escapeValue(league.id),
                    escapeValue(league.name),
                    escapeValue(country.name),
                    escapeValue(country.code),
                    escapeValue(JSON.stringify(seasons))
                ].join(",");
            })
        ];

        fs.writeFileSync(filePath, csvLines.join("\n"));
    } else if (type === "team") {
        const headers = ["team_id", "team_name", "code", "founded", "venue_id", "venue_name", "venue_address", "venue_city", "venue_capacity"];
        const csvLines = [
            headers.join(","),
            ...rows.map((row) => {
                const team = row.team || {};
                const venue = row.venue || {};
                return [
                    team.id,
                    team.name,
                    team.code,
                    team.founded,
                    venue.id,
                    venue.name,
                    venue.address,
                    venue.city,
                    venue.capacity
                ].map(escapeValue).join(",");
            })
        ];

        fs.writeFileSync(filePath, csvLines.join("\n"));
    }
};

/* Timezone utility methods */
const saveTzData = async (outputPath) => {
    const tz_data = await footballApi(tzUrl, apiKey);
    if (tz_data) {
        console.log(tz_data);
        saveJsonToCsv(tz_data.response ?? tz_data, outputPath, "timezone");
        console.log(`Saved data to ${outputPath}`);
    }
}

/* Countries utility methods */
// The API's /countries endpoint only accepts a single name/code/search filter,
// so a multi-country list has to be fetched in full and filtered client-side.
const loadCountryNames = (filePath) => {
    return fs.readFileSync(filePath, "utf-8")
        .split("\n")
        .map((line) => line.trim())
        .filter((line) => line.length > 0);
}

const saveCountriesData = async (outputPath, filterNames) => {
    const countries_data = await footballApi(countriesUrl, apiKey);
    if (countries_data) {
        const countries = countries_data.response ?? [];
        // Filter countries if filterNames is provided, otherwise use all countries
        const filtered = filterNames ? filterDataByName(countries, filterNames, "country") : countries;
        // console.log(filtered);
        saveJsonToCsv(filtered, outputPath, "country");
        console.log(`Saved data to ${outputPath}`);
    } else {
        console.error("Error fetching data from API.");
    }
}

/* Leagues utility methods */
export function loadLeagueNames(filePath) {
    return fs.readFileSync(filePath, "utf-8")
            .split("\n")
            .map((line) => line.trim())
            .filter((line) => line.length > 0);
}

export async function saveLeaguesData(outputPath, filterNames) {
    const leaguesData = await footballApi(leaguesUrl, apiKey);
    if(leaguesData){
        const leagues = leaguesData.response ?? leaguesData;
        // const jsonPath = path.join(currentDir, "leagues.json");
        // fs.writeFileSync(jsonPath, JSON.stringify(leagues));
        // console.log("League response data:", leagues);
        const filtered = filterNames ? filterDataByName(leagues, filterNames, "league") : leagues;
        console.log(filtered);
        saveJsonToCsv(filtered, outputPath, "league");
        console.log(`Saved data to ${outputPath}`);
    } else {
        console.error("Error fetching data from API.");
    }
}

/* Teams utility methods */
export async function saveTeamsData(url, outputPath) {
    const teamsData = await footballApi(url, apiKey);
    if (teamsData) {
        const teams = teamsData.response ?? [];
        saveJsonToCsv(teams, outputPath, "team");
        console.log(`Saved ${teams.length} teams to ${outputPath}`);
    } else {
        console.error("Error fetching data from API.");
    }
}

async function main() {
    /* Save timezone data */
    // await saveTzData(tzOutPath);

    /* Save countries data */
    // const euLeagueCountries = loadCountryNames(euLeagueCountriesPath);
    // await saveCountriesData(countriesOutPath, euLeagueCountries);

    /* Save leagues data */
    // const euLeagueNames = loadLeagueNames(euLeaguesPath);
    // await saveLeaguesData(leaguesCsvPath, euLeagueNames);

    /* Save teams data */
    await saveTeamsData(teamsUrl, teamsCsvPath);
}

main().catch((error) => {
    console.error("Error in main function:", error);
})