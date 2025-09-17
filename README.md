			Mini Streaming — SQL + Python

				О проекте
Учебный мини-стриминг: пользователи смотрят контент, ставят оценки и оформляют подписки. Тарифы ведём с историей версий (**SCD2**) — можно корректно отвечать на вопрос «что действовало на дату X».

				Модели
- Концептуальная (без нормализации): `docs/conceptual-model.mmd`
- Логическая (3НФ + SCD2): `docs/logical-model.mmd`
- Обоснование физической модели: `docs/physical-model.md`; - Диаграмма: `docs/physical-model.png` (экспорт из DBeaver)


> PNG-версии диаграмм (опционально на Днях 1–3):  
> `docs/conceptual-model.png`, `docs/logical-model.png` (экспорт через mermaid.live)

---

			Как запустить локально (Дни 1–3)

1) Подготовка окружения
1. Требования: Python 3.11+, PostgreSQL 16+, DBeaver (по желанию).
2. Установить зависимости:
   ```bash
   python -m venv .venv
   .\.venv\Scripts\activate
   pip install -r requirements.txt
