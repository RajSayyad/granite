import axios from "axios";

const fetch = axios.get("/tasks");
const taskApi = { fetch };

export default taskApi;
