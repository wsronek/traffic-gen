from locust import HttpUser, task

class APISecurityValidation(HttpUser):
    host = "https://sol-eng-lb2.perf.f5xc.app"

    @task
    def hello_world(self):
        self.client.get("/hello")
        self.client.get("/world")

    @task
    def index(self):
        self.client.get("/")

    @task
    def post_username_password(self):
        self.client.post("/login", {"username":"testuser", "password":"secret"})

    @task
    def post_username_password_json(self):
        self.client.post("/login", json={"username":"testuser", "password":"secret"})

    @task
    def view_items(self):
        for item_id in range(10):
            self.client.get(f"/item?id={item_id}", name="/item")
            time.sleep(1)