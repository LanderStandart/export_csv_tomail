from flask import (
    Flask,
    render_template,
    redirect,
    flash,
    url_for,
    session
)

from datetime import timedelta
from sqlalchemy.exc import (
    IntegrityError,
    DataError,
    DatabaseError,
    InterfaceError,
    InvalidRequestError,
)
from werkzeug.routing import BuildError

from flask_bcrypt import Bcrypt, generate_password_hash, check_password_hash

from flask_login import (
    UserMixin,
    login_user,
    LoginManager,
    current_user,
    logout_user,
    login_required,
)

from app import create_app, db, login_manager, bcrypt
from models import User
from forms import login_form, register_form,period_form,UserForm
from blueprints.Helpdesk.system.get_task import get_list


@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))


app = create_app()


@app.before_request
def session_handler():
    session.permanent = True
    app.permanent_session_lifetime = timedelta(minutes=1)


@app.route("/", methods=("GET", "POST"), strict_slashes=False)
def index():
    return render_template("index.html", title="Home")


@app.route("/login/", methods=("GET", "POST"), strict_slashes=False)
def login():
    form = login_form()

    if form.validate_on_submit():
        try:
            user = User.query.filter_by(email=form.email.data).first()
            if check_password_hash(user.pwd, form.pwd.data):
                login_user(user)
                return redirect(url_for('task'))
            else:
                flash("Invalid Username or password!", "danger")
        except Exception as e:
            flash(e, "danger")

    return render_template("auth.html",
                           form=form,
                           text="Login",
                           title="Login",
                           btn_action="Вход"
                           )


# # Register route
# @app.route("/register/", methods=("GET", "POST"), strict_slashes=False)
# def register():
#     form = register_form()
#     if form.validate_on_submit():
#         try:
#             email = form.email.data
#             pwd = form.pwd.data
#             username = form.username.data
#             agent_id =form.agent_id.data
#
#             newuser = User(
#                 username=username,
#                 email=email,
#                 pwd=bcrypt.generate_password_hash(pwd),
#                 agent_id=agent_id,
#             )
#
#             db.session.add(newuser)
#             db.session.commit()
#             flash(f"Account Succesfully created", "success")
#             return redirect(url_for("login"))
#
#         except InvalidRequestError:
#             db.session.rollback()
#             flash(f"Something went wrong!", "danger")
#         except IntegrityError:
#             db.session.rollback()
#             flash(f"User already exists!.", "warning")
#         except DataError:
#             db.session.rollback()
#             flash(f"Invalid Entry", "warning")
#         except InterfaceError:
#             db.session.rollback()
#             flash(f"Error connecting to the database", "danger")
#         except DatabaseError:
#             db.session.rollback()
#             flash(f"Error connecting to the database", "danger")
#         except BuildError:
#             db.session.rollback()
#             flash(f"An error occured !", "danger")
#     return render_template("auth.html",
#                            form=form,
#                            text="Create account",
#                            title="Register",
#                            btn_action="Register account"
#                            )


@app.route("/logout")
@login_required
def logout():
    logout_user()
    return redirect(url_for('login'))

## Маршрут для просмотра списка пользователей
@app.route('/users')
@login_required
def user_list():
    users = User.query.all()
    return render_template('user_list.html', users=users)

# Маршрут для добавления нового пользователя
@app.route('/users/add', methods=['GET', 'POST'])
@login_required
def add_user():
    form = UserForm()
    if form.validate_on_submit():
        user = User(
            username=form.username.data,
            email=form.email.data,
            pwd=bcrypt.generate_password_hash(form.pwd.data),  # В реальном приложении пароль должен быть хеширован!
            agent_id=form.agent_id.data
        )
        db.session.add(user)
        db.session.commit()
        flash('Пользователь успешно добавлен!', 'success')
        return redirect(url_for('user_list'))
    return render_template('user_form.html', form=form, title='Добавить пользователя')

# Маршрут для редактирования пользователя
@app.route('/users/edit/<int:id>', methods=['GET', 'POST'])
@login_required
def edit_user(id):
    user = User.query.get_or_404(id)
    form = UserForm(obj=user)
    if form.validate_on_submit():
        user.username = form.username.data
        user.email = form.email.data
        user.pwd = bcrypt.generate_password_hash(form.pwd.data),  # В реальном приложении пароль должен быть хеширован!
        user.agent_id = form.agent_id.data
        db.session.commit()
        flash('Пользователь успешно обновлён!', 'success')
        return redirect(url_for('user_list'))
    return render_template('user_form.html', form=form, title='Редактировать пользователя')

# Маршрут для удаления пользователя
@app.route('/users/delete/<int:id>', methods=['POST'])
@login_required
def delete_user(id):
    user = User.query.get_or_404(id)
    db.session.delete(user)
    db.session.commit()
    flash('Пользователь успешно удалён!', 'success')
    return redirect(url_for('user_list'))


@app.route("/task",methods=("GET", "POST"),)
@login_required
def task():
    form = period_form()
    # date_s = form.date_s.label
    # date_e = form.date_e.label
    # get_list('1530,1791')
    if form.validate_on_submit():
        date_s = form.date_s.data.strftime('%d.%m.%Y')
        date_e = form.date_e.data.strftime('%d.%m.%Y')
        print(f"Start Date: {date_s}, End Date: {date_e}")
        result=get_list('1530,1791',date_s,date_e)

        return render_template("tasklist.html",json_data=result,
                               date_s=date_s,
                               date_e=date_e)

    return render_template("task.html",
                           form=form,
                           title="Задачи",
                           )


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000,debug=True)