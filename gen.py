from locust import HttpUser, task

class APISecurityValidation(HttpUser):

    @task
    def hello_world(self):
        self.client.get("/hello")
        self.client.get("/world")

    @task
    def index(self):
        self.client.get("/")

    def post_username_password(self):
        self.client.post("/login", {"username":"testuser", "password":"secret"})

    def post_username_password_json(self):
        self.client.post("/login", json={"username":"testuser", "password":"secret"})