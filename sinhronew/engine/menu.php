<div>
   <span> 
    <nav class="navbar navbar-expand-md bg-dark navbar-dark">
      
        <a class="navbar-brand" href="./index.php"><div class="logo"></div> </a>
     

      <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#nav1">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div id="nav1" class="collapse navbar-collapse ">
        <ul class="navbar-nav mr-auto multi-level">
          <li class="nav-item" :=disabled=:><a class="nav-link" style="display: inline-block" href="./index.php" > Мониторинг синхронизации:=alert_upd=:</a></li>
          <li class="nav-item"><a class="nav-link" href="./malohod.php">Малоходовка <span class="badge badge-danger">:=count=:</span></a></li>

           <div class="dropdown">
            <a id="dLabel" role="button" data-toggle="dropdown" class="nav-link dropdown-toggle" data-target="#" href="/page.html">
                Настройки <span class="caret"></span>
            </a>
        <ul class="dropdown-menu multi-level" role="menu" aria-labelledby="dropdownMenu">
             <!--  <li><a class="dropdown-item" href="#">Some action</a></li>
              <li><a class="dropdown-item" href="#">Some other action</a></li>
              <li class="divider"></li> -->
              <li class="dropdown-submenu">
                <a class="dropdown-item" tabindex="-1" href="#">Серверы синхронизации</a>
                <ul class="dropdown-menu">
                  <!-- <li><a tabindex="-1" href="#">Second level</a></li>
                  <li class="dropdown-submenu">
                    <a href="#">Even More..</a>
                    <ul class="dropdown-menu">
                        <li><a href="#">3rd level</a></li>
                      <li><a href="#">3rd level</a></li>
                    </ul>
                  </li> -->
                  <li><a class="dropdown-item" href="./serverlist.php">Список серверов</a></li>
                  <li><a class="dropdown-item" data-toggle="modal" data-target="#myModal" href="#">Добавить новый сервер</a></li>
                  <li><a class="dropdown-item" href="./delete_server.php">Удалить сервер</a></li>
                </ul>
              </li>
            </ul>
        </div>

       <li class="nav-item"><a class="nav-link" href="./faq_sinhro.php">F.A.Q. Ошибки синхронизации </a></li>

         <!--  <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" id="navbardrop" data-toggle="dropdown">Настройки</a>
            
            <div class="dropdown-menu">
              <a class="nav-link dropdown-item" href="#" id="navbardrop" data-toggle="dropdown-submenu">Серверы синхронизации</a>
              <div class="dropdown-submenu"
                <a class="dropdown-item" href="./serverlist.php">Список серверов</a>
                <a class="dropdown-item"  data-toggle="modal" data-target="#myModal" href="#">Добавить новый сервер</a>
                <a class="dropdown-item" href="./delete_server.php">Удалить сервер</a>
              </div>  
            </div> 
          
          </li> -->

         <!--  <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" id="navbardrop" data-toggle="dropdown">Общий заказ KZ<span class="badge badge-warning">в разработке</span></a>
          <div class="dropdown-menu">
              <a class="dropdown-item" href="./oz_suppls.php">Поставщики</a>
              <a class="dropdown-item" href="./oz_clients.php">Получатели</a>
          </div> </li> -->


        <!-- The Modal -->
          <div class="modal" id="myModal">
            <div class="modal-dialog">
              <div class="modal-content">

                <!-- Modal Header -->
                <div class="modal-header">
                  <h4 class="modal-title">Добавление нового сервера</h4>
                  <button type="button" class="close" data-dismiss="modal">&times;</button>

                </div>

                <!-- Modal body -->
                <form action="./addserv.php" method="post">
                  <div class="modal-body">
                  
                      <div class="form-group">
                        <label for="nameserver">Имя сервера:</label>
                        <input type="nameserver" class="form-control" name="nameserver" id="nameserver">
                      </div>
                      <div class="form-group">
                        <label for="url">URL:</label>
                        <input type="url" class="form-control" name="url" id="url">
                      </div>
                  </div>
                  <!-- Modal footer -->
                  <div class="modal-footer">
                    <button type="submit" class="btn btn-primary">Добавить</button>
                    <button type="button" class="btn btn-danger" data-dismiss="modal">Отмена</button>
                  </div>
                </form>
              </div>
            </div>
          </div>

          <div class="modal" id="Update">
            <div class="modal-dialog">
              <div class="modal-content">
                <div class="modal-header">
                  <h4 class="modal-title">Обновляем данные</h4>   
                </div>
                <div class="modal-body"> 
                Подождите !!!  
                </div>

              </div>
            </div> 
          </div>

        </ul>
      </div>
    </nav>
  </span>
</div>

<div class="container">

<script type="text/javascript"> 
            
      $('#Update').on('show.bs.modal', function() {
       
        document.location.href = "./getdata.php";
  
      })
</script>