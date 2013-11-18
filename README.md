# Diddy

Diddy is a simple script/scenario runner that is a mix between Spinach, Cucumber and/or Steak. Diddy is not specificly targeted for testing frameworks.  

At this moment we use Diddy to full integration tests on our various production servers to check if everything works nicely together. We use this in combination 
with the awesome Mechanize gem. 

## How it works

First define a script and some scenario's:


    Diddy::Script.define('Test product X') do

      scenario "Checking if app works" do
        uses AdminSteps
        uses FrontendSteps
        uses ApiSteps

        step "Login to backend"
        step "Create fake user"
        step "Login to frontend with fake user"
        step "Do some stuff"
        step "Check if API works"
      end
    end

Then, define your steps:


    class AdminSteps < Diddy::Steps
      step "Login to backend" do
        # do some stuff
      end

      step "Create fake user" do
      end
    end

Note: every step, needs to return true. If not: the step fails. Make sure you define your steps so that they always return a true or false depending on it's action.

## Dynamic/sub steps

    class AdminSteps < Diddy::Steps
      step "Test if site works" do
        sub_step "Visit root page" do
        end

        sub_step "Download assets" do
        end

        sub_step "Check if texts are correct" do
        end
      end

## Scoping

Every step definition class, has it own scope. To share variables between step definitions, use the shared object:


    class AdminSteps < Diddy::Steps
      step "Create fake user" do
        shared[:user_id] = HttpParty.post("http://admin.example.com/users", { name: 'Har' }).body.to_i
      end
    end

    class FrontendSteps < Diddy::Steps
      step "Do some stuff" do
        HttpParty.get("http://www.example.com/api/#{shared[:user_id]}")
      end
    end

This "shared" state (the state of the steps class and the shared vars), lives until a script is finished.

## Run the whole thing

After defining your scripts, instantiate a result logger and let the monkey do it's work:

    run_log = Diddy::RunResult.new
    Diddy::Script.run(run_log, 'Script name')

Or, only one scenario:

    ...
    some_script = Diddy::Script.scripts.first
    Diddy::Script.run(run_log, some_script)

## Context

It could be usefull to run the same script in another context. In that case you can pass variables around that you can use in your script/scenario:

    Diddy::Script.run(run_log, 'Product X', { country: 'us' })
    Diddy::Script.run(run_log, 'Product X', { country: 'uk' })

    ...

    step "Fetch current configuration" do
      grab_config "http://api.example.com/#{context[:country]}"
      ...
    end
