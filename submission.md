## Links

Link to GitHub classroom: https://github.com/NU-CS-Software-Studio-Spring-26/nu-cs-software-studio-spring-26-homework-5-hw5

Link to .cursorignore: https://github.com/NU-CS-Software-Studio-Spring-26/homework-5-yaslynm/blob/hw5/.cursorignore

Link to AGENTS.md: https://github.com/NU-CS-Software-Studio-Spring-26/homework-5-yaslynm/blob/hw5/AGENTS.md

Link to .cursor/rules/rails-convention: https://github.com/NU-CS-Software-Studio-Spring-26/homework-5-yaslynm/blob/hw5/.cursor/rules/rails-conventions.mdc

Link to .cursor/rules/security.mdc: https://github.com/NU-CS-Software-Studio-Spring-26/homework-5-yaslynm/blob/hw5/.cursor/rules/security.mdc



## Part 3 - Ask Mode

Prompt: Where in this codebase is the todo create form implemented? Cite the exact files and line numbers and do not propose changes.

The todo create form is split across a shared partial, a new-todo page, controller actions, a route, and an index link.

Form markup (shared partial)
The form itself is in app/views/todos/_form.html.erb:


_form.html.erb
Lines 1-22
<%= form_with(model: todo) do |form| %>
  <% if todo.errors.any? %>
    <div style="color: red">
      <h2><%= pluralize(todo.errors.count, "error") %> prohibited this todo from being saved:</h2>
      <ul>
        <% todo.errors.each do |error| %>
          <li><%= error.full_message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>
  <div>
    <%= form.label :description, style: "display: block" %>
    <%= form.text_field :description %>
  </div>
  <div>
    <%= form.submit %>
  </div>
<% end %>
Lines 1–22: form_with(model: todo) builds the form; because todo is a new record on create, it POSTs to /todos.
Lines 14–17: The only input field is description.
Lines 19–20: Submit button (Rails labels it “Create Todo” for a new record).
Create page (renders the form)
app/views/todos/new.html.erb is the create page that includes the partial:


new.html.erb
Lines 1-11
<% content_for :title, "New todo" %>
<h1>New todo</h1>
<%= render "form", todo: @todo %>
<br>
<div>
  <%= link_to "Back to todos", todos_path %>
</div>
Line 5: Renders _form.html.erb with @todo.
On failed create, the controller re-renders this same template (see below).

Controller (loads and submits the form)
app/controllers/todos_controller.rb:


todos_controller.rb
Lines 13-16
  # GET /todos/new
  def new
    @todo = Todo.new
  end

todos_controller.rb
Lines 22-35
  # POST /todos or /todos.json
  def create
    @todo = Todo.new(todo_params)
    respond_to do |format|
      if @todo.save
        format.html { redirect_to @todo, notice: "Todo was successfully created." }
        format.json { render :show, status: :created, location: @todo }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @todo.errors, status: :unprocessable_content }
      end
    end
  end

todos_controller.rb
Lines 74-76
    def todo_params
      params.expect(todo: [ :description ])
    end
Lines 14–16: new instantiates @todo for the form.
Lines 23–35: create handles form submission.
Line 31: On validation failure, re-renders new.html.erb (and thus _form.html.erb) with errors.
Lines 74–76: Strong params — only :description is accepted from the form.
Route
config/routes.rb:


routes.rb
Lines 1-2
Rails.application.routes.draw do
  resources :todos
resources :todos defines GET /todos/new → new and POST /todos → create.

Entry point link
app/views/todos/index.html.erb:


index.html.erb
Lines 16-16
<%= link_to "New todo", new_todo_path %>
This is the link from the index page to the create form.

Note on reuse
The same _form.html.erb partial is also used by the edit page at app/views/todos/edit.html.erb line 5 (<%= render "form", todo: @todo %>), but the create flow specifically goes through new.html.erb → _form.html.erb → TodosController#create.

Verification: I opened the citations/files Cursor returned and can confirm they are real.

## Part 3 - Plan Mode

Prompt: I want to change todo creation so that users must enter a description before they create a todo. Propose a plan as a numbered list of
changes, including files to edit, new tests to add, and any migration. Do not write
code.

Response: Require Description on Todo Creation

Current state





[app/models/todo.rb](app/models/todo.rb) has no validations; description is nullable in [db/schema.rb](db/schema.rb) (line 15).



[app/controllers/todos_controller.rb](app/controllers/todos_controller.rb) create (lines 23–35) already re-renders :new with 422 when @todo.save fails.



[app/views/todos/_form.html.erb](app/views/todos/_form.html.erb) (lines 2–11) already displays todo.errors.



[test/models/todo_test.rb](test/models/todo_test.rb) is empty (no model tests yet).

flowchart TD
  submit[User submits create form] --> create[TodosController#create]
  create --> save["@todo.save"]
  save -->|valid| redirect[Redirect to show]
  save -->|invalid| rerender["render :new with errors"]
  rerender --> form["_form.html.erb shows errors"]

Numbered changes

Add model validation — edit [app/models/todo.rb](app/models/todo.rb)

Add validates :description, presence: true.

This rejects nil and blank strings (e.g. "", "   ").

Applies on both create and update (standard Rails behavior; also prevents clearing description on edit).

No controller changes — [app/controllers/todos_controller.rb](app/controllers/todos_controller.rb)

create already calls @todo.save and renders :new on failure (lines 27–32).

todo_params already permits :description (lines 74–76).

update also benefits from the same validation without changes.

Optional form UX — edit [app/views/todos/_form.html.erb](app/views/todos/_form.html.erb)

Add required: true to the description text_field (line 16) for browser-level prompting.

Server-side validation in step 1 remains the source of truth; this is optional client-side UX only.

No migration required

Model-level presence validation is sufficient to enforce the rule at the application layer.

The existing description column (t.string, nullable) does not need to change.

A DB NOT NULL migration is optional hardening but not needed for this feature; fixtures already use non-blank values (test/fixtures/todos.yml).

Add model tests — edit [test/models/todo_test.rb](test/models/todo_test.rb)

test "is valid with a description" — Todo.new(description: "Buy milk") is valid.

test "is invalid without a description" — Todo.new(description: nil) is invalid; assert errors[:description] is present.

test "is invalid with a blank description" — Todo.new(description: "") (and optionally "   ") is invalid.

Add controller integration test — edit [test/controllers/todos_controller_test.rb](test/controllers/todos_controller_test.rb)

test "should not create todo without description" — POST { todo: { description: "" } } (or omit description).

Assert Todo.count unchanged.

Assert response is 422 Unprocessable Content (or :unprocessable_entity depending on Rails assertion helper).

Assert response body re-renders the new form (e.g. contains "New todo").

Add system test — edit [test/system/todos_test.rb](test/system/todos_test.rb)

test "should not create todo without description" — visit new form, leave Description empty, click "Create Todo".

Assert error text appears (e.g. "prohibited this todo from being saved" or "Description can't be blank").

Assert success notice does not appear.

Verify

Run bin/rails test and confirm all new and existing tests pass.

Manually submit an empty create form in the browser to confirm the error block in _form.html.erb renders.

Files touched (summary)

File

Action

[app/models/todo.rb](app/models/todo.rb)

Edit — add validation

[app/views/todos/_form.html.erb](app/views/todos/_form.html.erb)

Optional edit — required: true

[test/models/todo_test.rb](test/models/todo_test.rb)

Edit — add 2–3 tests

[test/controllers/todos_controller_test.rb](test/controllers/todos_controller_test.rb)

Edit — add 1 test

[test/system/todos_test.rb](test/system/todos_test.rb)

Edit — add 1 test

No new files. No migration.

## Part 3 - Agent Mode

Prompt: Can you add validates :description, presence: true to app/models/todo.rb

Commit: https://github.com/NU-CS-Software-Studio-Spring-26/nu-cs-software-studio-spring-26-homework-5-hw5/commit/dcc263d7cbf602d5c5fcffffdd22a8ee81ad2e64

## Part 3 - Good and Bad Prompt

Bad prompt: "fix the bug in todos"

Good prompt: 

Context: The relevant files are app/models/todo.rb, db/schema.rb, and the migration that created the todos table.
Task: Add a database-level constraint so that a Todo description cannot be null. The application currently validates description presence in the model, but the database schema does not enforce this rule.
Expected vs. actual: Expected behavior is that all Todo records must have a description regardless of whether they are created through the Rails UI, Rails console, seeds, or direct SQL. Actual behavior is that the model validation prevents blank descriptions through the application, but the database still allows records with a null description.
Constraints: Use a Rails migration and follow existing Rails 8 conventions. Do not add any gems. Do not remove the existing model validation. Ensure the migration is reversible and preserves existing data.
Done when: The todos table has a database constraint preventing null descriptions, the existing model validation remains in place, migrations run successfully, and attempts to create a Todo with a null description at the database level fail.

## Part 4 

Turbo Streams explanation:

Turbo Streams are a feature of Rails which allows developers to update parts of a page without having to perform a full page reload.

AI explained to me that Turbo Stream responses are handle using respond_to with format.turbo_stream in the controller. This is something I was able to verify by checking the Turbo Streams documentation and cross-checking it with my own implementation. 

PR URL: https://github.com/NU-CS-Software-Studio-Spring-26/homework-5-yaslynm/pull/1