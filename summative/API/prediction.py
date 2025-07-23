from fastapi import FastAPI
from pydantic import BaseModel, Field
from fastapi.middleware.cors import CORSMiddleware
from enum import Enum
import joblib
import pandas as pd

class OrganisationEnum(str, Enum):
    AEB = "AEB"
    AMBA = "AMBA"
    ASI = "ASI"
    Arianespace = "Arianespace"
    Armee_de_l_Air = "Armée de l'Air"
    Blue_Origin = "Blue Origin"
    Boeing = "Boeing"
    CASC = "CASC"
    CASIC = "CASIC"
    CECLES = "CECLES"
    CNES = "CNES"
    Douglas = "Douglas"
    EER = "EER"
    ESA = "ESA"
    Eurockot = "Eurockot"
    ExPace = "ExPace"
    Exos = "Exos"
    General_Dynamics = "General Dynamics"
    IAI = "IAI"
    ILS = "ILS"
    IRGC = "IRGC"
    ISA = "ISA"
    ISAS = "ISAS"
    ISRO = "ISRO"
    JAXA = "JAXA"
    KARI = "KARI"
    KCST = "KCST"
    Khrunichev = "Khrunichev"
    Kosmotras = "Kosmotras"
    Land_Launch = "Land Launch"
    Landspace = "Landspace"
    Lockheed = "Lockheed"
    MHI = "MHI"
    MITT = "MITT"
    Martin_Marietta = "Martin Marietta"
    NASA = "NASA"
    Northrop = "Northrop"
    OKB_586 = "OKB-586"
    OneSpace = "OneSpace"
    RAE = "RAE"
    RVSN_USSR = "RVSN USSR"
    Rocket_Lab = "Rocket Lab"
    Roscosmos = "Roscosmos"
    SRC = "SRC"
    Sandia = "Sandia"
    Sea_Launch = "Sea Launch"
    SpaceX = "SpaceX"
    Starsem = "Starsem"
    ULA = "ULA"
    US_Air_Force = "US Air Force"
    US_Navy = "US Navy"
    UT = "UT"
    VKS_RF = "VKS RF"
    Virgin_Orbit = "Virgin Orbit"
    Yuzhmash = "Yuzhmash"
    i_Space = "i-Space"

class RocketStatusEnum(str, Enum):
    StatusActive = "StatusActive"
    StatusRetired = "StatusRetired"

class MissionStatusEnum(str, Enum):
    Failure = "Failure"
    Partial_Failure = "Partial Failure"
    Prelaunch_Failure = "Prelaunch Failure"
    Success = "Success"

class CountryEnum(str, Enum):
    Australia = "Australia"
    Barents_Sea = "Barents Sea"
    Brazil = "Brazil"
    China = "China"
    France = "France"
    Gran_Canaria = "Gran Canaria"
    India = "India"
    Iran = "Iran"
    Israel = "Israel"
    Japan = "Japan"
    Kazakhstan = "Kazakhstan"
    Kenya = "Kenya"
    New_Mexico = "New Mexico"
    New_Zealand = "New Zealand"
    North_Korea = "North Korea"
    Pacific_Missile_Range_Facility = "Pacific Missile Range Facility"
    Pacific_Ocean = "Pacific Ocean"
    Russia = "Russia"
    Shahrud_Missile_Test_Site = "Shahrud Missile Test Site"
    South_Korea = "South Korea"
    USA = "USA"
    Yellow_Sea = "Yellow Sea"


le_organisation = joblib.load("le_organisation.pkl")
le_rocket_status = joblib.load("le_rocket_status.pkl")
le_mission_status = joblib.load("le_mission_status.pkl")
le_country = joblib.load("le_country.pkl")
scaler_year = joblib.load("scaler_year.pkl")
pipeline = joblib.load("decision_tree_pipeline.pkl")

app = FastAPI(
    title="Launch Price Prediction API",
    description="Predicts launch price based on raw values using a Decision Tree pipeline."
)

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -----------------------------
# Input Schema
# -----------------------------
class LaunchData(BaseModel):
    Year: int = Field(..., ge=1950, le=2100, description="Year of launch (1950-2100)")
    Organisation: OrganisationEnum
    Rocket_Status: RocketStatusEnum
    Mission_Status: MissionStatusEnum
    Country: CountryEnum

@app.post("/predict")
def predict(data: LaunchData):
    df = pd.DataFrame([data.dict()])
    
    # Encode categorical variables
    df["Organisation_encoded"] = le_organisation.transform(df["Organisation"])
    df["Rocket_Status_encoded"] = le_rocket_status.transform(df["Rocket_Status"])
    df["Mission_Status_encoded"] = le_mission_status.transform(df["Mission_Status"])
    df["Country_encoded"] = le_country.transform(df["Country"])
    
    # Scale numerical variable
    df["Year_scaled"] = scaler_year.transform(df[["Year"]])
    
    feature_order = [
    'Year_scaled',
    'Organisation_encoded',
    'Rocket_Status_encoded',
    'Mission_Status_encoded',
    'Country_encoded'
    ]
    # Select features expected by the model
    X = df[feature_order]
    
    prediction = pipeline.predict(X)
    return {"predicted_price_million_usd": float(prediction[0])}

@app.get("/")
def home():
    return {"message": "Welcome to the Launch Price Prediction API! Visit /docs for Swagger UI."}
