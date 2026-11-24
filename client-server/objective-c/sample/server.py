import argparse
import json
from http.server import BaseHTTPRequestHandler, HTTPServer


class CheckoutHandler(BaseHTTPRequestHandler):
    def send_json(self, status, value):
        body = json.dumps(value).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self):
        if self.path != "/checkout":
            self.send_json(404, {"error": "Unknown route"})
            return

        try:
            length = int(self.headers["Content-Length"])
            if length < 0:
                raise ValueError
            basket = json.loads(self.rfile.read(length))
            items = basket["items"]
            if not isinstance(items, list):
                raise ValueError

            total = 0
            for item in items:
                price, quantity = item["price_kopecks"], item["quantity"]
                if type(price) is not int or price < 0 or type(quantity) is not int or quantity < 1:
                    raise ValueError
                total += price * quantity
        except (KeyError, TypeError, ValueError):
            self.send_json(400, {"error": "Invalid basket"})
            return

        self.send_json(200, {"total_kopecks": total})


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, default=9100)
    args = parser.parse_args()
    with HTTPServer(("127.0.0.1", args.port), CheckoutHandler) as server:
        server.serve_forever()
