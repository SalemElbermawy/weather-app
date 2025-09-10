exports.handler = async function(event, context) {
  try {
    const city = event.queryStringParameters.city;
    const apiKey = "YOUR_API_KEY"; // حط مفتاح OpenWeather بتاعك هنا

    // Fetch data from OpenWeather API
    const response = await fetch(
      `https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${apiKey}`
    );

    if (!response.ok) {
      return {
        statusCode: response.status,
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Headers": "Content-Type",
        },
        body: JSON.stringify({ error: "Failed to fetch weather data" }),
      };
    }

    const data = await response.json();

    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type",
      },
      body: JSON.stringify(data),
    };
  } catch (error) {
    return {
      statusCode: 500,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type",
      },
      body: JSON.stringify({ error: error.message }),
    };
  }
};
