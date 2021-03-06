#' @rdname report_model
#' @examples
#' model <- lm(Sepal.Length ~ Species, data = iris)
#' report_intercept(model)
#'
#' library(lme4)
#' model <- lme4::lmer(Sepal.Length ~ Petal.Length + (1 | Species), data = iris)
#' report_intercept(model)
#' @export
report_intercept <- function(model, parameters, ...) {
  UseMethod("report_intercept")
}







#' @export
report_intercept.lm <- function(model, parameters = NULL, ci = 0.95, ...) {
  .report_intercept_regression(model, parameters = NULL, ci = ci, ...)
}

#' @export
report_intercept.glm <- report_intercept.lm

#' @export
report_intercept.merMod <- report_intercept.lm




#' @keywords internal
.report_intercept_regression <- function(model, parameters = NULL, ci = 0.95, ...) {
  if (is.null(parameters)) {
    parameters <- parameters::model_parameters(model, ci = ci, ...)
  }

  intercept <- parameters[parameters$Parameter == "(Intercept)", ]

  coefficient <- names(parameters)[names(parameters) %in% c("Coefficient", "Median", "Mean", "MAP")][1]
  is_at <- insight::format_value(intercept[[coefficient]])

  intercept[[coefficient]] <- NULL

  text <- paste0(
    " The model's intercept is at ",
    insight::format_value(is_at),
    "."
  )
  text_full <- paste0(
    " The model's intercept",
    .find_intercept(model),
    " is at ",
    insight::format_value(is_at),
    " (",
    .report_parameters_indices(intercept, ci = ci),
    ")."
  )

  text_full <- gsub("std. beta", "std. intercept", text_full, fixed = TRUE)

  as.model_text(text, text_full)
}




#' @keywords internal
.find_intercept <- function(model) {

  # Intercept-only
  if (all(insight::find_parameters(model, flatten = FALSE) == "(Intercept)")) {
    return("")
  }

  terms <- insight::find_variables(model)$conditional
  data <- insight::get_data(model)[terms %in% names(insight::get_data(model))]
  text <- c()
  for (col in names(data)) {
    if (is.numeric(data[[col]])) {
      text <- c(text, paste0(col, " = 0"))
    } else if (is.character(data[[col]])) {
      data[col] <- as.character(data[col])
      text <- c(text, paste0(col, " = ", levels(data[[col]])[1]))
    } else if (is.factor(data[[col]])) {
      text <- c(text, paste0(col, " = ", levels(data[[col]])[1]))
    } else {
      text <- c(text, paste0(col, " = [?]"))
    }
  }
  paste0(", corresponding to ", format_text(text), ",")
}
