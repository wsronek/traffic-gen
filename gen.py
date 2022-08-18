import time
import random
from locust import HttpLocust, HttpUser, between, task
from locust.clients import HttpSession

products = [
    '0PUK6V6EV0',
    '1YMWWN1N4O',
    '2ZYFJ3GM2N',
    '66VCHSJNUP',
    '6E92ZMYYFZ',
    '9SIQT8TOJO',
    'L9ECAV7KIM',
    'LS4PSXUNUM',
    'OLJCESPC7Z']

class APISecurityValidation(HttpUser):
    host = "https://sol-eng-lb2.perf.f5xc.app"

    wait_time = between(3, 10)

    def on_start(self):
        self.client.headers = {"User-Agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.51 Safari/537.36"}

    @task
    def methods_head(self):
        self.client.head("/")

    @task
    def create_different_paths(self):
        for path_id in range(1000):
            self.client.get(f"/dynpath{path_id}")
            time.sleep(1)

    @task
    def get_review(self):
        self.client.get("/review")

    @task
    def index(self):
        self.client.get("/")

    @task
    def post_username_password(self):
        for path_id in range(1000):
            self.client.post(f"/login{path_id}", {"username":"testuser", "password":"secret"})

    @task
    def post_username_password_json(self):
        self.client.post("/login", json={"username":"testuser", "password":"secret"})

    @task
    def view_items(self):
        for item_id in range(10):
            self.client.get(f"/item?id={item_id}", name="/item")
            time.sleep(1)

    @task
    def setCurrency(self):
        currencies = ['EUR', 'USD', 'JPY', 'CAD']
        self.client.post("/setCurrency",
            {'currency_code': random.choice(currencies)})

    @task
    def browseProduct(self):
        self.client.get("/product/" + random.choice(products))

    @task
    def viewCart(self):
        self.client.get("/cart")

    @task
    def addToCart(self):
        product = random.choice(products)
        self.client.get("/product/" + product)
        self.client.post("/cart", {
            'product_id': product,
            'quantity': random.choice([1,2,3,4,5,10])})

    @task
    def checkout(self):
        self.addToCart()
        self.client.post("/cart/checkout", {
            'email': 'someone@example.com',
            'street_address': '1600 Amphitheatre Parkway',
            'zip_code': '94043',
            'city': 'Mountain View',
            'state': 'CA',
            'country': 'United States',
            'credit_card_number': '4432-8015-6152-0454',
            'credit_card_expiration_month': '1',
            'credit_card_expiration_year': '2039',
            'credit_card_cvv': '672',
        })