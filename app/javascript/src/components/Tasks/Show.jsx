import React, { useEffect, useState } from "react";

import tasksApi from "apis/tasks";
import { Button, Container, PageLoader } from "components/commons";
import { useHistory, useParams } from "react-router-dom";

const Show = () => {
  const [task, setTask] = useState([]);
  const [pageLoading, setPageLoading] = useState(true);
  const { slug } = useParams();
  const history = useHistory();

  const updateTask = () => {
    history.push(`/tasks/${task.slug}/edit`);
  };

  const fetchTaskDetails = async () => {
    try {
      const response = await tasksApi.show(slug);
      setTask(response.data);
      setPageLoading(false);
    } catch (error) {
      logger.error(error);
      history.push("/");
    }
  };

  useEffect(() => {
    fetchTaskDetails();
  }, []);

  if (pageLoading) {
    return <PageLoader />;
  }

  return (
    <Container>
      <div className="flex flex-col gap-y-8">
        <div className="mt-8 flex w-full items-start justify-between gap-x-6">
          <div className="flex flex-col gap-y-2">
            <h2 className="text-3xl font-semibold">{task?.task?.title}</h2>
            <div className="flex items-center gap-x-6">
              <p className="text-base text-gray-700">
                <span className="font-semibold">Assigned to: </span>
                {task?.assigned_user?.name}
              </p>
            </div>
          </div>
          <Button
            buttonText="Edit"
            icon="edit-line"
            size="small"
            style="secondary"
            onClick={updateTask}
          />
        </div>
      </div>
    </Container>
  );
};

export default Show;
