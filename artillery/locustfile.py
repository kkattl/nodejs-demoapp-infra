from locust import HttpUser, task, between
class WebsiteUser(HttpUser):
    wait_time = between(0.5, 1)
    @task
    def index(self):
        self.client.get("/")
