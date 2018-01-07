from flask import Flask
from flask import render_template
app = Flask(__name__)

app.config.from_object('config')

@app.route("/")
def index():
    """
    The Home Page for our app
    """

    return render_template('index.html')

@app.route("/loadgen")
def loadgen():
    """
    A Web Page that generates load for perf testing
    """

    from time import time
    # Params to set up the workload
    iterations = 300000
    i = 0
    x = 2
    # Ready Set go (capture start time)
    start = time()
    # do the useless work to generate CPU load
    while i < iterations:
        x = x * 2
        i += 1
    # We're done
    end = time()
    # Figure out the elapsed Seconds
    seconds = end - start
    # Pass it all to the template for presentation
    return render_template('loadgen.html', iters=iterations,
            duration = seconds)

if __name__ == "__main__":
    app.run()
