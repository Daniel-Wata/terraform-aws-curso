resource "aws_alb" "main" {
    name = local.name_prefix
    load_balancer_type = "application"
    internal = false 

    security_groups = [aws_security_group.alb.id]
    subnets = aws_subnet.public[*].id

    enable_deletion_protection = false
}

resource "aws_alb_listener" "http" {
    load_balancer_arn = aws_alb.main.arn 
    port = 80
    protocol = "HTTP"

    default_action {
      type = "fixed-response"

      fixed_response {
        content_type = "text/html"
        status_code = "200"
        message_body = <<-HTML
        <!doctype html>
        <html lang="pt-br">
          <meta charset="utf-8">
          <title>Aula 02</title>
          <body style="font-family: sans-serif; max-width: 48rem; margin: 4rem auto; padding: 0 1rem">
            <h1>Rede pronta.</h1>
            <p>O caminho Internet &rarr; ALB esta funcionando.</p>
            <p>Na Aula 03, esta entrada recebe dominio e HTTPS.</p>
          </body>
        </html>
      HTML
      }
    }
}
